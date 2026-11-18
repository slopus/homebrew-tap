import assert from "node:assert/strict";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";
import { assertSmokeReport, runApp } from "./smoke.mjs";

function report() {
  return {
    packaged: true, platform: "linux", arch: "arm64", welcomeVisible: true,
    screenshotWritten: true, hiddenMode: true, dockVisible: null,
    focusedWindow: false, analyticsEnabled: false, rendererHosted: false,
    windows: [{ visible: false, focused: false }],
  };
}

test("only a native packaged hidden welcome with analytics off passes", () => {
  assert.doesNotThrow(() => assertSmokeReport(report(), "linux", "arm64"));
  assert.doesNotThrow(() => assertSmokeReport({ ...report(), platform: "darwin", dockVisible: false }, "darwin", "arm64"));
  for (const invalid of [
    { packaged: false }, { platform: "darwin" }, { arch: "x64" },
    { welcomeVisible: false }, { screenshotWritten: false }, { hiddenMode: false },
    { dockVisible: true }, { focusedWindow: true }, { analyticsEnabled: true },
    { analyticsEnabled: null }, { rendererHosted: true }, { windows: [] },
    { windows: [{ visible: true, focused: false }] },
    { windows: [{ visible: false, focused: true }] },
  ]) assert.throws(() => assertSmokeReport({ ...report(), ...invalid }, "linux", "arm64"));
});

test("launcher retains output and records nonzero exits, timeouts, and inherited pipes", async () => {
  const root = await mkdtemp(join(tmpdir(), "happy-launch-test-"));
  try {
    const options = { cwd: root, env: process.env, logPath: join(root, "app.log"), timeout: 2000, drainTimeout: 100 };
    await runApp(process.execPath, ["-e", 'console.log("hello"); console.error("stderr")'], options);
    assert.match(await readFile(options.logPath, "utf8"), /hello/);
    assert.match(await readFile(options.logPath, "utf8"), /stderr/);
    await assert.rejects(runApp(process.execPath, ["-e", "process.exit(7)"], options), /exited 7/);
    assert.equal(JSON.parse(await readFile(`${options.logPath}.json`, "utf8")).code, 7);
    await assert.rejects(runApp(process.execPath, ["-e", 'console.log("before hang"); setInterval(() => {}, 1000)'], { ...options, timeout: 500 }), /timed out/);
    assert.match(await readFile(options.logPath, "utf8"), /before hang/);
    assert.equal(JSON.parse(await readFile(`${options.logPath}.json`, "utf8")).timedOut, true);
    // A live helper inherits stdout, but the main process exits successfully.
    await runApp(process.execPath, ["-e", 'require("node:child_process").spawn(process.execPath, ["-e", "setInterval(() => {}, 1000)"], { stdio: "inherit" }).unref()'], options);
    const lifecycle = JSON.parse(await readFile(`${options.logPath}.json`, "utf8"));
    assert.equal(lifecycle.code, 0);
    assert.equal(lifecycle.pipesClosed, undefined);
    await assert.rejects(runApp(join(root, "missing"), [], options), /ENOENT/);
  } finally {
    await rm(root, { recursive: true, force: true });
  }
});