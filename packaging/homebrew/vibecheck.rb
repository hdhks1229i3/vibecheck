class Vibecheck < Formula
  desc "The vibe check for your code"
  homepage "https://github.com/copyleftdev/vibecheck"
  version "1.0.0"
  license "MIT"

  # TODO: Update these URLs and SHA256s after creating the GitHub Release

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/copyleftdev/vibecheck/releases/download/v1.0.0/vibecheck-aarch64-macos.tar.gz"
      sha256 "REPLACE_WITH_SHA256"
    elsif Hardware::CPU.intel?
      url "https://github.com/copyleftdev/vibecheck/releases/download/v1.0.0/vibecheck-x86_64-macos.tar.gz"
      sha256 "REPLACE_WITH_SHA256"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/copyleftdev/vibecheck/releases/download/v1.0.0/vibecheck-x86_64-linux.tar.gz"
      sha256 "REPLACE_WITH_SHA256"
    end
  end

  def install
    bin.install "vibecheck"
  end

  test do
    assert_match "VibeCheck", shell_output("#{bin}/vibecheck --help")
  end
end
