cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.97"
  sha256 arm:          "a95144f0a2c9bebad08b4c6047ab2074f1349ee34bc743ba78f4288b39fa29a3",
         intel:        "f0599dd7ac20f2dc0f8c66192592d620d358c2919abc81271cdc41e6b275161d",
         arm64_linux:  "8228c3746fb9654e860b11b9cd81939ab212a6d4c66a8d4cdb644c459de3cfc8",
         x86_64_linux: "4f47314ef611d3cdaa5f315b1838120d8f8a86b1e52403106503d8d4f607030d"

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
