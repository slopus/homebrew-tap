cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.88"
  sha256 arm:          "25aeb0b309db322d5cd80bd60e929261e8ae3211b4c4d1db3a18a27fdda8ff80",
         intel:        "d1a714be82d755cdf12533ac8c48e1e59f72e1d5f7ceca5d42fe7f2bc58bc44a",
         arm64_linux:  "c959c77982104139991b88deae4e3c41360c50471315ccdd471612d9e5297ca4",
         x86_64_linux: "40cf35127176f59af0abdd18c0d4d68d54b2ef4ea20eeb482a5474e2e760470a"

  on_macos do
    url "https://github.com/slopus/happy-desktop/releases/download/v#{version}/Happy-#{version}-#{arch}.dmg"

    auto_updates true

    app "Happy.app"
  end
  on_linux do
    url "https://github.com/slopus/happy-desktop/releases/download/v#{version}/Happy-#{version}-#{arch}.AppImage"

    app_image "Happy-#{version}-#{arch}.AppImage", target: "Happy.AppImage"
    binary "Happy-#{version}-#{arch}.AppImage", target: "happy-desktop"
  end

  name "Happy"
  desc "Agent-first desktop workspace"
  homepage "https://happy.engineering/desktop/"

  livecheck do
    url "https://github.com/slopus/happy-desktop/releases/latest"
    strategy :github_latest
  end
end
