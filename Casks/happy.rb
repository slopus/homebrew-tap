cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.94"
  sha256 arm:          "785ff73308f1175eb0b8bff388f7c9f3b4d84f5e3ca19e267e16062fce4eadfa",
         intel:        "4641453f8a3fa49b21d77bbcda431d22dea3eb7235bd6770da466f4a45f1d241",
         arm64_linux:  "e2011f6f8f1bce8d0fe83639c740a650001bf43b4b13ca550c911f09cc1bb4a0",
         x86_64_linux: "411505c5e6ef2dbca2ab714f39ea57873a2c5b19220d78dae7c915ea7a9ed520"

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
