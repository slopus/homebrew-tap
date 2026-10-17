cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.98"
  sha256 arm:          "44b964a900e0027aee60bfb8eecb2f7010b43125734119af8c801f2ba4542e82",
         intel:        "193411a1638a397e847296325f1ebf362a95e1a3bf679198a535d5464bd5728a",
         arm64_linux:  "5672ab4eab07380214a7dd84ec613efc36c2447aa39aee010cc46e999ee640b3",
         x86_64_linux: "c64a5beef7addcbf79eada50fb83ac540268b355959348b660741be69602252f"

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
