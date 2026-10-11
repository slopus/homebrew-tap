cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.95"
  sha256 arm:          "f94dab76d202a5d0318a3a1fec4476a9bad8ee2ea8957555aecc77550e7aef87",
         intel:        "175ca3d3b43f715c070bd1935799bb7634e67fcd57761ee9b32c17c4c3c9bc4c",
         arm64_linux:  "eed3b622cef1ef057da8fc25c5e30948fa9502f594c17d6b678176f8d0209eb5",
         x86_64_linux: "e0f6e72894709a36828c75e957949666ae32794e1e7f7d2017fcd9129bdb0586"

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
