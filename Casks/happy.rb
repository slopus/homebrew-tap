cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.100"
  sha256 arm:          "30cd6c222f8eb948890c4faca78ee90523dcf46e84fffee5778ad004d2270441",
         intel:        "acabaa6ed8888f7fb331612ac4d6f7da9a14ea7ab322634af1ad1794772a7512",
         arm64_linux:  "e27c47b2a8d51deffe0f29d3010a2d61d9cdd51c428d40566b802cd094bfc752",
         x86_64_linux: "edfdcd5601db848bc1bdcfadfcba5090f69577914081f0613a64c04159748653"

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
