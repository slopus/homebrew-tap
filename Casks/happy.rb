cask "happy" do
  arch arm: "arm64", intel: "x64"

  version "0.0.86"
  sha256 arm:          "750daf408e8ae75d8f34f6716ca655af7f76ee416dec3930ad571e607ec29b39",
         intel:        "af97913e3a331a62562164ca8ddd1eb8daf5bf85941175db3222a53c6690e623",
         arm64_linux:  "735921e6fbe1c43d32e027bf9d998f6e01d1a9af65b29247a7e43f3afddedeca",
         x86_64_linux: "64ff6336519067f36149f1dca09c18d2818f081567c4de659fc2656c5316f4bc"

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
