import { readFile, writeFile } from "node:fs/promises";
import { pathToFileURL } from "node:url";

const repository = "slopus/happy-desktop";

export function caskFromRelease(release) {
  if (release.draft || release.prerelease || !/^v\d+\.\d+\.\d+$/.test(release.tag_name)) {
    throw new Error("Only a published stable desktop release can update happy.");
  }
  const version = release.tag_name.slice(1);
  const prefix = `https://github.com/${repository}/releases/download/v${version}/`;
  function checksum(arch, extension) {
    const name = `Happy-${version}-${arch}.${extension}`;
    const matches = release.assets.filter((asset) => asset.name === name);
    if (matches.length !== 1) throw new Error(`Expected exactly one ${name}.`);
    const asset = matches[0];
    if (
      asset.state !== "uploaded" ||
      asset.size <= 0 ||
      asset.browser_download_url !== `${prefix}${name}`
    ) {
      throw new Error(`Invalid upstream asset: ${name}.`);
    }
    if (!/^sha256:[a-f0-9]{64}$/.test(asset.digest))
      throw new Error(`Missing SHA-256 for ${name}.`);
    return asset.digest.slice(7);
  }
  const macArm = checksum("arm64", "dmg");
  const macIntel = checksum("x64", "dmg");
  const linux = release.assets.some((asset) =>
    /^Happy-[\d.]+-(x64|arm64)\.AppImage$/.test(asset.name),
  );
  const linuxChecksums = linux
    ? `,\n         arm64_linux:  "${checksum("arm64", "AppImage")}",\n         x86_64_linux: "${checksum("x64", "AppImage")}"`
    : "";
  return `cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "${version}"
  sha256 arm:${linux ? "          " : "   "}"${macArm}",
         intel:${linux ? "        " : " "}"${macIntel}"${linuxChecksums}

  on_macos do
    url "https://github.com/slopus/happy-desktop/releases/download/v#{version}/Happy-#{version}-#{arch}.dmg"

    auto_updates true

    app "Happy.app"
  end
${
  linux
    ? `  on_linux do
    url "https://github.com/slopus/happy-desktop/releases/download/v#{version}/Happy-#{version}-#{arch}.AppImage"

    app_image "Happy-#{version}-#{arch}.AppImage", target: "Happy.AppImage"
    binary "Happy-#{version}-#{arch}.AppImage", target: "happy-desktop"
  end
`
    : ""
}
  name "Happy"
  desc "Agent-first desktop workspace"
  homepage "https://happy.engineering/desktop/"

  livecheck do
    url "https://github.com/slopus/happy-desktop/releases/latest"
    strategy :github_latest
  end
${linux ? "" : "\n  depends_on :macos\n"}end
`;
}

export function assertNoDowngrade(current, next) {
  if (current.includes("app_image ") && !next.includes("app_image ")) {
    throw new Error("Refusing to drop Linux support from a new release.");
  }
  const previous = current.match(/^  version "(\d+\.\d+\.\d+)"$/m)?.[1];
  const candidate = next.match(/^  version "(\d+\.\d+\.\d+)"$/m)?.[1];
  if (!previous || !candidate) throw new Error("Cannot compare cask versions.");
  const a = previous.split(".").map(Number);
  const b = candidate.split(".").map(Number);
  for (let i = 0; i < 3; i++) {
    if (b[i] > a[i]) return;
    if (b[i] < a[i]) throw new Error(`Refusing downgrade ${previous} -> ${candidate}.`);
  }
  // Published artifacts must not be silently replaced under an existing version.
  if (current.trimEnd() !== next.trimEnd())
    throw new Error(`Release ${previous} changed without a version bump.`);
}

async function main() {
  const headers = { Accept: "application/vnd.github+json" };
  if (process.env.GH_TOKEN) headers.Authorization = `Bearer ${process.env.GH_TOKEN}`;
  const response = await fetch(`https://api.github.com/repos/${repository}/releases/latest`, {
    headers,
    signal: AbortSignal.timeout(30_000),
  });
  if (!response.ok) throw new Error(`GitHub release lookup failed: ${response.status}.`);
  const cask = caskFromRelease(await response.json());
  const path = new URL("../Casks/happy.rb", import.meta.url);
  const current = await readFile(path, "utf8").catch((error) => {
    if (error.code === "ENOENT") return undefined;
    throw error;
  });
  if (current !== undefined) assertNoDowngrade(current, cask);
  await writeFile(path, cask);
  console.log(cask.match(/^  version .+$/m)[0].trim());
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) await main();
