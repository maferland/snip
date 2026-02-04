cask "snip" do
  version "2.0.0"
  sha256 :no_check

  url "https://github.com/maferland/clean-copy/releases/download/v#{version}/Snip-v#{version}-macos.dmg"
  name "Snip"
  desc "Automatically strip tracking parameters from copied URLs"
  homepage "https://github.com/maferland/clean-copy"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :sonoma"

  app "Snip.app"

  zap trash: [
    "~/Library/Preferences/com.maferland.snip.plist",
  ]
end
