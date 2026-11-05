import assert from "node:assert/strict";
import { execFile, spawn } from "node:child_process";
import { mkdir, mkdtemp, readFile, rm, stat, writeFile } from "node:fs/promises";
import { dirname, resolve, join } from "node:path";
import { promisify } from "node:util";

// Run only on disposable CI runners: never launch or install over a user's app.
if (process.env.CI !== "true")
  throw new Error("Homebrew boot checks require a disposable CI runner.");
const executablePath = process.env.HAPPY_CASK_EXECUTABLE;
const version = process.env.HAPPY_CASK_VERSION;
if (!executablePath || !version) throw new Error("Missing installed executable/version.");
const artifacts = resolve("artifacts");
await mkdir(artifacts, { recursive: true });
const profile = await mkdtemp(join(process.env.RUNNER_TEMP, "happy-cask-smoke-"));
const reportPath = join(profile, "smoke-report.json");
const screenshotPath = join(artifacts, "welcome.png");
const home = join(profile, "home");
await mkdir(home);
const env = {
  ...process.env,
  HOME: home,
  USERPROFILE: home,
  HAPPY_HOME_DIR: join(home, ".happy"),
  HAPPY_DESKTOP_WINDOWS_HIDDEN: "1",
  HAPPY_DESKTOP_SMOKE_REPORT: reportPath,
  HAPPY_DESKTOP_SMOKE_SCREENSHOT: screenshotPath,
};
delete env.HAPPY_AGENT_SERVER_SOCKET_PATH;
delete env.HAPPY_AGENT_SERVER_TOKEN_PATH;
let output = "";
try {
  // Version is not in Desktop's smoke report. Check the installed bundle on
  // macOS, and Homebrew's installed AppImage URL/version on Linux instead.
  let installedVersion;
  let versionSource;
  if (process.platform === "darwin") {
    const { stdout } = await promisify(execFile)("plutil", [
      "-extract", "CFBundleShortVersionString", "raw", "-o", "-",
      join(dirname(dirname(executablePath)), "Info.plist"),
    ]);
    installedVersion = stdout.trim();
    versionSource = "CFBundleShortVersionString";
  } else {
    assert.equal(process.platform, "linux");
    const { casks } = JSON.parse(await readFile("cask-info.json", "utf8"));
    assert.equal(casks.length, 1);
    installedVersion = casks[0].version;
    const architecture = { arm64: "arm64", x64: "x64" }[process.arch];
    assert.ok(architecture, `Unsupported architecture: ${process.arch}`);
    assert.ok(
      casks[0].url.endsWith(`/Happy-${version}-${architecture}.AppImage`),
      "Homebrew must install the expected version and architecture's AppImage.",
    );
    versionSource = "Homebrew cask metadata and AppImage URL";
  }
  assert.equal(installedVersion, version, "Installed version must match the cask.");

  // Packaged Happy refuses raw debugger switches. Its own release smoke
  // launches normally, writes this report and screenshot, then quits.
  // No inspector, remote-debugging, or --no-sandbox arguments are passed.
  const child = spawn(executablePath, [`--user-data-dir=${join(profile, "user-data")}`], {
    env,
    stdio: ["ignore", "pipe", "pipe"],
  });
  const keepOutput = (data) => { output = (output + String(data)).slice(-1_048_576); };
  child.stdout.on("data", keepOutput);
  child.stderr.on("data", keepOutput);
  const exit = await new Promise((resolveExit, reject) => {
    const timer = setTimeout(() => {
      child.kill("SIGKILL");
      reject(new Error(`Happy did not report and quit within 120 seconds:\n${output}`));
    }, 120_000);
    child.once("error", (error) => {
      clearTimeout(timer);
      reject(error);
    });
    child.once("close", (code, signal) => {
      clearTimeout(timer);
      resolveExit({ code, signal });
    });
  });
  assert.equal(exit.code, 0, `Happy exited with ${exit.signal ?? exit.code}:\n${output}`);
  const report = JSON.parse(await readFile(reportPath, "utf8").catch((error) => {
    throw new Error(`Happy exited without a smoke report:\n${output}`, { cause: error });
  }));
  const evidence = { ...report, version: installedVersion, versionSource };
  await writeFile(join(artifacts, "boot.json"), JSON.stringify(evidence, null, 2) + "\n");
  assert.equal(report.packaged, true);
  assert.equal(report.platform, process.platform);
  assert.equal(report.arch, process.arch);
  // The released report does not expose rendererErrors. Its rendered welcome
  // screen and capture are the same evidence Desktop's release jobs require.
  assert.equal(report.welcomeVisible, true);
  assert.equal(report.screenshotWritten, true);
  assert.ok((await stat(screenshotPath)).size > 0);
  assert.equal(report.hiddenMode, true);
  assert.notEqual(report.dockVisible, true);
  assert.equal(report.focusedWindow, false);
  assert.ok(Array.isArray(report.windows));
  for (const window of report.windows) {
    assert.equal(window.visible, false);
    assert.equal(window.focused, false);
  }
  console.log(JSON.stringify(evidence));
} finally {
  await writeFile(join(artifacts, "electron.log"), output);
  await rm(profile, { recursive: true, force: true });
}
