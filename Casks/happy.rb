cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.93"
  sha256 arm:          "6ec597d34725649b35255028faeb767de2cda9107144dd6e5a4b48ee6c945996",
         intel:        "3bc936c5774b7e0cbcd9666b9d8d1bcf387fe98735026b3a9f230a768e346503",
         arm64_linux:  "f7418e3594f41abe6a97a407182d81a216aca16c7226203ba19babfc9c18e377",
         x86_64_linux: "b30c9715d1237435ee84495296d12c971362656570599b8391cfc5a8b7613889"

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
