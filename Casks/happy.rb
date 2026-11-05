cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.103"
  sha256 arm:          "c2f4a7ac49659804b0173a52d42a16a9beb93843912f4828c1624b3ed9be31e5",
         intel:        "f9ed87fde287afab96786819929e72a6630ae5e6e5e454cf8c92d90f0cf8c0cf",
         arm64_linux:  "38a36f8bcb4ffde0d475b987f666f37bf473c47875db9ba23e3dd79cb2492a11",
         x86_64_linux: "c92db95656d3181435329156b2bf6c84ba57c1cb7ee36c9ac67ac74c7ed82c25"

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
