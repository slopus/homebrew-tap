cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.99"
  sha256 arm:          "b59b26b32af6a2edb3d57099619d5ebba64802c735227b88934a4771ec06253a",
         intel:        "e581fe4b07a7808c1ed3b611b52bbf526cd26f13ea5a6bd81474038f3738c11a",
         arm64_linux:  "f15b14930e363ca66f8a5811df347332fb3bb100b93cd192a638687f89bf7943",
         x86_64_linux: "55037baa4f9b8757e6ee347ab8a7cd593d7ca714cb1edf4ecffdbd35d8559d2a"

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
