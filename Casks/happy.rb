cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "2026.11.4"
  sha256 arm:          "04def81a9769ab76ce1bf6a7df39b78ced0d85a93c28ab04c57eccef66fd6c88",
         intel:        "b035002eb93ae84a0d547f12d91d881b714fa858bf23bf783e855e07d63f393d",
         arm64_linux:  "23ceefc4e7be8e8472197c2c3fd61e2a84a3e6dac272166f27de23cf6e9861d2",
         x86_64_linux: "ce61267a7c39b1938b0fea45fb753cd254d91ffa3bd1dcdfca5670f2d40d48b6"

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
