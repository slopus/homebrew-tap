cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.102"
  sha256 arm:          "0cc70d0dfb4f4eefc691901df182f459062df3bf3f7b33b3959b9005ae1be3b3",
         intel:        "05122d27d5f4dc7912b1eb104a2e191f2eb16b227f69e6540bac80a32e7fd158",
         arm64_linux:  "8570d9853772027eb17afcbf1e37edcd5f08a6e3c84127b29b0b6f7a94f11b7a",
         x86_64_linux: "c3d606434ccffe64c64a68d005d8799c5c47bd35aba3a894e0baedaa28a7907f"

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
