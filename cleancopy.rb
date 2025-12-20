cask "cleancopy" do
  version "1.1.0"
  sha256 "75a5dc4ea9d990395d86c8c421ceb07c137b3d8beaee90e6bbf83cccffe1fcdc"

  url "https://github.com/maferland/clean-copy/releases/download/v#{version}/CleanCopy-v#{version}-macos.dmg",
      verified: "github.com/maferland/clean-copy/"
  name "CleanCopy"
  desc "Automatically strip tracking parameters from copied URLs"
  homepage "https://github.com/maferland/clean-copy"

  livecheck do
    url :url
    strategy :github_latest
  end

  binary "CleanCopy"

  zap trash: "~/Library/LaunchAgents/com.cleancopy.launcher.plist"
end
