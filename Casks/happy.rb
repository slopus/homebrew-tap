cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.96"
  sha256 arm:          "a8465e6174f7d1ab0f89e13da8edf4d1a3b39232f9ddf36fe6fd285f49ffef2a",
         intel:        "82af7c4d9be86ef04b794ce0a86273a4546fb13e52038afd067e81dde7f7db1d",
         arm64_linux:  "4502853f7fe9fb65b6fcd76fe5ceb40b4904bcb7df33fefd208008ea7e39c96a",
         x86_64_linux: "217b0fc5079139a68528e2fb5e7ecb9844079043228a37763e2546d9e94ea393"

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
