import assert from "node:assert/strict";
import { execFileSync, spawn } from "node:child_process";
import { createWriteStream } from "node:fs";
import { mkdir, mkdtemp, readFile, writeFile } from "node:fs/promises";
import { dirname, resolve, join } from "node:path";
import { pathToFileURL } from "node:url";
import { extractFile } from "@electron/asar";

// The packaged app refuses debugger switches. Its supported hidden smoke mode
// renders the real welcome screen, writes a report/capture, and quits itself.
export function assertSmokeReport(report, platform = process.platform, arch = process.arch) {
  assert.equal(report.packaged, true);
  assert.equal(report.platform, platform);
  assert.equal(report.arch, arch);
  assert.equal(report.welcomeVisible, true);
  assert.equal(report.screenshotWritten, true);
  assert.equal(report.hiddenMode, true);
  assert.equal(report.dockVisible, platform === "darwin" ? false : null);
  assert.equal(report.focusedWindow, false);
  assert.equal(report.analyticsEnabled, false);
  assert.equal(report.rendererHosted, false);
  assert.ok(Array.isArray(report.windows) && report.windows.length > 0);
  for (const window of report.windows) {
    assert.equal(window.visible, false);
    assert.equal(window.focused, false);
  }
}

export async function runApp(executable, args, options) {
  const log = createWriteStream(options.logPath);
  const child = spawn(executable, args, { cwd: options.cwd, env: options.env, detached: true, stdio: ["ignore", "pipe", "pipe"] });
  child.stdout.pipe(log, { end: false });
  child.stderr.pipe(log, { end: false });
  const lifecycle = { startedAt: new Date().toISOString(), executable, args };
  const stopGroup = () => {
    if (child.pid) {
      try { process.kill(-child.pid, "SIGKILL"); }
      catch (error) { if (error.code !== "ESRCH") throw error; }
    }
  };
  const closed = new Promise((resolve) => child.once("close", resolve));
  let timedOut = false;
  const timer = setTimeout(() => {
    timedOut = true;
    stopGroup();
  }, options.timeout ?? 120_000);
  try {
    const exitCode = await new Promise((resolve, reject) => {
      child.once("error", reject);
      // A helper may retain an output pipe after the main app has exited.
      // Observe the main process independently, then bound pipe draining below.
      child.once("exit", (code, signal) => {
        Object.assign(lifecycle, { exitedAt: new Date().toISOString(), code, signal });
        if (timedOut) reject(new Error(`Packaged app timed out; see ${options.logPath}.`));
        else if (signal) reject(new Error(`Packaged app exited on ${signal}; see ${options.logPath}.`));
        else resolve(code);
      });
    });
    assert.equal(exitCode, 0, `Packaged app exited ${exitCode}; see ${options.logPath}.`);
  } finally {
    clearTimeout(timer);
    let drainTimer;
    await Promise.race([
      closed.then(() => { lifecycle.pipesClosed = true; }),
      new Promise((resolve) => { drainTimer = setTimeout(resolve, options.drainTimeout ?? 5000); }),
    ]);
    clearTimeout(drainTimer);
    stopGroup();
    child.stdout.destroy();
    child.stderr.destroy();
    await new Promise((resolve) => log.end(resolve));
    await writeFile(`${options.logPath}.json`, JSON.stringify({ ...lifecycle, timedOut }, null, 2));
  }
}

async function main() {
  // Never launch or install over a person's application or Happy data.
  if (process.env.CI !== "true" || !process.env.RUNNER_TEMP)
    throw new Error("Homebrew boot checks require a disposable CI runner.");
  const executable = process.env.HAPPY_CASK_EXECUTABLE;
  const version = process.env.HAPPY_CASK_VERSION;
  if (!executable || !version) throw new Error("Missing installed executable/version.");
  const artifacts = resolve("artifacts");
  await mkdir(artifacts, { recursive: true });
  const profile = await mkdtemp(join(process.env.RUNNER_TEMP, "happy-cask-smoke-"));
  const home = join(profile, "home");
  await mkdir(home);
  const env = {
    ...process.env,
    HOME: home,
    USERPROFILE: home,
    XDG_CONFIG_HOME: join(home, ".config"),
    XDG_CACHE_HOME: join(home, ".cache"),
    XDG_DATA_HOME: join(home, ".local", "share"),
    HAPPY_HOME_DIR: join(home, ".happy"),
    DO_NOT_TRACK: "1",
    HAPPY_DESKTOP_WINDOWS_HIDDEN: "1",
    HAPPY_DESKTOP_SMOKE_REPORT: join(artifacts, "smoke-report.json"),
    HAPPY_DESKTOP_SMOKE_SCREENSHOT: join(artifacts, "welcome.png"),
  };
  delete env.HAPPY_AGENT_SERVER_SOCKET_PATH;
  delete env.HAPPY_AGENT_SERVER_TOKEN_PATH;
  delete env.ELECTRON_RUN_AS_NODE;
  delete env.ELECTRON_DISABLE_SANDBOX;
  delete env.NODE_OPTIONS;
  let archive;
  if (process.platform === "darwin") {
    archive = resolve(dirname(executable), "..", "Resources", "app.asar");
  } else if (process.platform === "linux") {
    // Read the installed AppImage's metadata without launching another app.
    await runApp(executable, ["--appimage-extract", "resources/app.asar"], {
      cwd: profile, env, logPath: join(artifacts, "appimage-extract.log"),
    });
    archive = join(profile, "squashfs-root", "resources", "app.asar");
  } else {
    throw new Error(`Unsupported smoke platform: ${process.platform}.`);
  }
  const metadata = JSON.parse(extractFile(archive, "package.json").toString());
  await writeFile(join(artifacts, "installed-package.json"), JSON.stringify({ version: metadata.version }, null, 2));
  assert.equal(metadata.version, version, "Installed package version must match the cask.");
  const architecture = execFileSync("file", ["-L", executable], { encoding: "utf8" });
  await writeFile(join(artifacts, "installed-architecture.txt"), architecture);
  assert.match(architecture, process.arch === "arm64" ? /arm64|aarch64/ : /x86[-_]64/);
  // The old published pin predates Desktop's report protocol. This is only an
  // explicitly labelled baseline; candidate/updater jobs never set this flag.
  if (version === "0.0.102" && process.env.HAPPY_CASK_LEGACY_BASELINE === "1") {
    const message = "Legacy 0.0.102 baseline: installed checksum, package version and native architecture verified. This release has no smoke-report protocol; no launch pass is claimed.";
    await writeFile(join(artifacts, "legacy-baseline.txt"), `${message}\n`);
    console.log(message);
    return;
  }
  await runApp(executable, [`--user-data-dir=${join(profile, "user-data")}`, "--enable-automation"], {
    cwd: profile, env, logPath: join(artifacts, "electron.log"),
  });
  const report = JSON.parse(await readFile(env.HAPPY_DESKTOP_SMOKE_REPORT, "utf8"));
  assertSmokeReport(report);
  const screenshot = await readFile(env.HAPPY_DESKTOP_SMOKE_SCREENSHOT);
  assert.ok(screenshot.length > 24 && screenshot.subarray(0, 8).equals(Buffer.from("89504e470d0a1a0a", "hex")), "Smoke must write a PNG capture.");
  assert.ok(screenshot.readUInt32BE(16) > 0 && screenshot.readUInt32BE(20) > 0, "Capture must have nonzero dimensions.");
  await writeFile(join(artifacts, "boot.json"), JSON.stringify({ ...report, version }, null, 2));
  console.log(JSON.stringify({ version, platform: report.platform, arch: report.arch, welcomeVisible: true }));
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) await main();