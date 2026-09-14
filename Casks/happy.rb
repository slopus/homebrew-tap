cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.85"
  sha256 arm:          "ab31f19271771c3a0c6eae72b8521f9013eea91f4ab1075569609f7c8bfbc8e5",
         intel:        "200eb5038ca0352f74bc7f3e20564c8b8170b1dc86049243ca0c8fcbae0db421",
         arm64_linux:  "3b4ba4e6aeb9a6109042c9ab4e5bada1520675bd02bf34f6ec08cddf2e707777",
         x86_64_linux: "823a933e9954d94343796d690e07d46be41f0c4d7fe4ca39ea95bc6a24f7c43e"

  on_macos do
    url "https://github.com/slopus/happy-desktop/releases/download/v#{version}/Happy-#{version}-#{arch}.dmg"

    auto_updates true

    app "Happy.app"
  end
  on_linux do
    url "https://github.com/slopus/happy-desktop/releases/download/v#{version}/Happy-#{version}-#{arch}.AppImage"

    app_image "Happy-#{version}-#{arch}.AppImage", target: "Happy.AppImage"
    binary "Happy-#{version}-#{arch}.AppImage", target: "happy-desktop"
  end

  name "Happy"
  desc "Agent-first desktop workspace"
  homepage "https://happy.engineering/desktop/"

  livecheck do
    url "https://github.com/slopus/happy-desktop/releases/latest"
    strategy :github_latest
  end
end
