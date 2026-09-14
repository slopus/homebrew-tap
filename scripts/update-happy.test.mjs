import assert from "node:assert/strict";
import test from "node:test";
import { assertNoDowngrade, caskFromRelease } from "./update-happy.mjs";

function release(linux = false) {
  return {
    tag_name: "v1.2.3",
    draft: false,
    prerelease: false,
    assets: ["arm64.dmg", "x64.dmg", ...(linux ? ["arm64.AppImage", "x64.AppImage"] : [])].map(
      (suffix) => ({
        name: `Happy-1.2.3-${suffix}`,
        browser_download_url: `https://github.com/slopus/happy-desktop/releases/download/v1.2.3/Happy-1.2.3-${suffix}`,
        state: "uploaded",
        size: 123,
        digest: `sha256:${"a".repeat(64)}`,
      }),
    ),
  };
}

test("macOS-only release does not claim Linux support", () => {
  const cask = caskFromRelease(release());
  assert.match(cask, /depends_on :macos/);
  assert.doesNotMatch(cask, /app_image/);
});
test("complete release selects both OSes and four checksums", () => {
  const cask = caskFromRelease(release(true));
  assert.match(cask, /arm64_linux:/);
  assert.match(cask, /x86_64_linux:/);
  assert.match(cask, /app_image/);
  assert.doesNotMatch(cask, /depends_on :macos/);
});
test("reject previews, drafts, incomplete Linux, duplicates, missing hashes, and foreign URLs", () => {
  for (const mutate of [
    (r) => {
      r.prerelease = true;
    },
    (r) => {
      r.draft = true;
    },
    (r) => {
      r.tag_name = "v1.2.3-preview.1";
    },
    (r) => {
      r.assets.pop();
    },
    (r) => {
      r.assets.push(r.assets[0]);
    },
    (r) => {
      r.assets[0].digest = null;
    },
    (r) => {
      r.assets[0].browser_download_url = "https://example.com/other.dmg";
    },
  ]) {
    const input = release(true);
    mutate(input);
    assert.throws(() => caskFromRelease(input));
  }
});
test("versions only move forward; same-version asset replacement is refused", () => {
  const current = caskFromRelease(release());
  assert.doesNotThrow(() => assertNoDowngrade(current, current));
  assert.doesNotThrow(() =>
    assertNoDowngrade(current, current.replace('version "1.2.3"', 'version "1.2.10"')),
  );
  assert.throws(() =>
    assertNoDowngrade(current, current.replace('version "1.2.3"', 'version "1.2.2"')),
  );
  assert.throws(() => assertNoDowngrade(current, caskFromRelease(release(true))));
  assert.throws(() =>
    assertNoDowngrade(
      caskFromRelease(release(true)),
      current.replace('version "1.2.3"', 'version "1.2.4"'),
    ),
  );
});
