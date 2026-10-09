cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.92"
  sha256 arm:          "b39630512c9db8891d98c97ce5c23465cecd8caac98d1b2596e7a0325b72e2aa",
         intel:        "026aefee8fda34aa48de0e5804b5952dc258e71ff11242de0d450ad95e6672a0",
         arm64_linux:  "9086ab1c8db40fdf4265ff39c594384e919da639727e72da0ea28f679d9ebf3d",
         x86_64_linux: "d19576c2d7ff99ae94fd17bd4d1cd2b22efd62356266d53b1aab853908806408"

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
