cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.90"
  sha256 arm:          "cf7aeb0ea1e802ce713f9e98c2848c7f7650f5c29f6d33a0774e4c6cbc6827b4",
         intel:        "71bfa29101d15571b15541423c52e525c646903501bc27fe56ce7ed1a7444da0",
         arm64_linux:  "47fd6d10c39a08928546eba2b7206fb7bb460573b0041f52ed393cad2f60affa",
         x86_64_linux: "26d3d059c343f1a7d343446b3c44a26764278b4ba17df28a454e1af03df1c9ef"

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
