cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.87"
  sha256 arm:          "c3750d74ff7d57afdbb14530da8a8db2954d55ded901ac516f851945f9313e7d",
         intel:        "d539fcf8cf3c3cded17ccfdad699aadf4ec6baf21324e183214e1c67b09adbab",
         arm64_linux:  "10ba607d7e0a8f08ba39e513b2eaedbc021bfa986ddd47503a731869885a3402",
         x86_64_linux: "33bf95e02844a96e5ea3adadd7cdee5cd5ed3d05f644fba00c53bcf94e1603ea"

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
