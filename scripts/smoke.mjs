import assert from "node:assert/strict";
import { mkdir, mkdtemp, writeFile } from "node:fs/promises";
import { resolve, join } from "node:path";
import { _electron as electron } from "playwright";

// Run only on disposable CI runners: never launch or install over a user's app.
if (process.env.CI !== "true")
  throw new Error("Homebrew boot checks require a disposable CI runner.");
const executablePath = process.env.HAPPY_CASK_EXECUTABLE;
const version = process.env.HAPPY_CASK_VERSION;
if (!executablePath || !version) throw new Error("Missing installed executable/version.");
const artifacts = resolve("artifacts");
await mkdir(artifacts, { recursive: true });
const profile = await mkdtemp(join(process.env.RUNNER_TEMP, "happy-cask-smoke-"));
const env = { ...process.env, HAPPY_HOME_DIR: join(profile, "happy") };
delete env.HAPPY_AGENT_SERVER_SOCKET_PATH;
delete env.HAPPY_AGENT_SERVER_TOKEN_PATH;
const app = await electron.launch({
  executablePath,
  // Playwright otherwise injects --no-sandbox, unlike a normal user launch.
  chromiumSandbox: true,
  args: [`--user-data-dir=${join(profile, "user-data")}`],
  env,
  timeout: 60_000,
});
const errors = [];
app.process().stderr?.on("data", (data) => errors.push(String(data)));
try {
  const identity = await app.evaluate(({ app }) => ({
    packaged: app.isPackaged,
    version: app.getVersion(),
    platform: process.platform,
    arch: process.arch,
  }));
  assert.deepEqual(identity, {
    packaged: true,
    version,
    platform: process.platform,
    arch: process.arch,
  });
  const page = await app.firstWindow();
  const pageErrors = [];
  page.on("pageerror", (error) => {
    pageErrors.push(error.message);
    errors.push(error.stack ?? error.message);
  });
  await page
    .locator('[data-happy-desktop-ui="welcome-screen"]')
    .waitFor({ state: "visible", timeout: 60_000 });
  assert.deepEqual(pageErrors, [], "Renderer must boot without uncaught errors.");
  await page.screenshot({ path: join(artifacts, "welcome.png") });
  await writeFile(
    join(artifacts, "boot.json"),
    JSON.stringify({ ...identity, welcomeVisible: true }, null, 2),
  );
  console.log(JSON.stringify({ ...identity, welcomeVisible: true }));
} finally {
  await writeFile(join(artifacts, "electron.log"), errors.join("\n"));
  await app.close();
}
