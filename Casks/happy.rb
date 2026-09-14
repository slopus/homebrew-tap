cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.84"
  sha256 arm:   "ea4d3e8790522c35daf41aea82a89c8d650f24743f353467856673cb7db0e37d",
         intel: "406d5e71e5ba6d6f052207608d78883421848b4b10ba5094e0f036e8f75a47b3"

  on_macos do
    url "https://github.com/slopus/happy-desktop/releases/download/v#{version}/Happy-#{version}-#{arch}.dmg"

    auto_updates true

    app "Happy.app"
  end

  name "Happy"
  desc "Agent-first desktop workspace"
  homepage "https://happy.engineering/desktop/"

  livecheck do
    url "https://github.com/slopus/happy-desktop/releases/latest"
    strategy :github_latest
  end

  depends_on :macos
end
