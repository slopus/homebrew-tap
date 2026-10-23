cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.101"
  sha256 arm:          "0bb1ce60bb0c51507b4531a02e0c5e0a79c4bbc86d6e462acb8dd79a6588eb2c",
         intel:        "3bb8e0abdcca30b1bf072c870ee64eb9aa4012bcdfab52c98c8acda85e419c02",
         arm64_linux:  "b97d55acd2dbb74e981e813e4193fadbd10bda0622a7cd68f651f46434f73807",
         x86_64_linux: "15c37a99d5d65a78554e1e2ead930f232cfdbf1a2bf69d3cd2af6c6b9a2ec0f3"

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
