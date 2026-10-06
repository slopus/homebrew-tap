cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.89"
  sha256 arm:          "3703c9c9634f5a10b0a03a608b97580b0984434271d763d6802acd8ac267e74e",
         intel:        "cb65c31d02588273ad6371efdfe33216e0d11e53d170e275196df9aad6a9c597",
         arm64_linux:  "e221c7e857b8aba975c3d3aa9d9076bc36ec764669d88d6c2f38eb530debff0f",
         x86_64_linux: "29fa86239259497cddb2c35670eb3372a065bb5e4849dd061557506c36a49fbc"

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
