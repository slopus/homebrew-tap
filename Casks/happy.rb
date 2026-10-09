cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.91"
  sha256 arm:          "1028da07790bfa74866e7b5610eb65e87cd0a8c49697603436dc8993f63a5c1a",
         intel:        "b3dba37c2fafdc1ca1c1f61ca98e367d8de7829abfc7df36b0c92789ef3e707d",
         arm64_linux:  "bce47195cd96d708732aa6f11a7473c0e130180cc537ec7d8134ce4819afd52d",
         x86_64_linux: "49a4948f3195e86c6a854bdcf756c2e781f6a7a6e30075846d6572b493097fdb"

  on_macos do
    url "https://github.com/slopus/happy-desktop/releases/download/v#{version}/Happy-#{version}-#{arch}.dmg"

    auto_updates true

    app "Happy.app"

    caveats <<~EOS
      Happy is a desktop app, not a terminal command. To open it:
        1. Press Cmd+Space to open Spotlight.
        2. Type "Happy" and press Return.
      Happy is installed at #{appdir}/Happy.app; `open -a Happy` also works.

      A `happy` command in your terminal is the older Happy CLI, not this app.
    EOS
  end
  on_linux do
    url "https://github.com/slopus/happy-desktop/releases/download/v#{version}/Happy-#{version}-#{arch}.AppImage"

    app_image "Happy-#{version}-#{arch}.AppImage", target: "Happy.AppImage"
    binary "Happy-#{version}-#{arch}.AppImage", target: "happy-desktop"

    caveats <<~EOS
      Launch Happy with `happy-desktop`, or open ~/Applications/Happy.AppImage.

      A `happy` command in your terminal is the older Happy CLI, not this app.
    EOS
  end

  name "Happy"
  desc "Agent-first desktop workspace"
  homepage "https://happy.engineering/desktop/"

  livecheck do
    url "https://github.com/slopus/happy-desktop/releases/latest"
    strategy :github_latest
  end
end
