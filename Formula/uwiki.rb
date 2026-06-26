# Reference Homebrew formula for https://github.com/FrantaNautilus/homebrew-uwiki
#
# Recommended layout in the tap repository:
#   Formula/uwiki.rb
#
# This formula prefers prebuilt binaries from GitHub Releases (produced by the
# release.yml workflow in the main uwiki repo on v* tags).
#
# It falls back to building from source for --HEAD.
#
# After tagging vX.Y.Z:
#   - The release workflow attaches assets like:
#       uwiki-vX.Y.Z-aarch64-apple-darwin.tar.gz
#       uwiki-vX.Y.Z-x86_64-unknown-linux-gnu.tar.gz
#       uwiki-vX.Y.Z-aarch64-unknown-linux-gnu.tar.gz
#     (and their .sha256 files)
#
#   - Update the version, urls and sha256 values below (or automate the update).
#
# Shell completions are generated from the installed binary at install time.

class Uwiki < Formula
  desc "Pure-Rust CLI knowledge manager for AI agents"
  homepage "https://github.com/FrantaNautilus/uwiki"
  license "MIT"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/FrantaNautilus/uwiki/releases/download/v#{version}/uwiki-v#{version}-aarch64-apple-darwin.tar.gz"
      sha256 "5084b20f723eea0699d6c4ab649a0b7a3893aa8412a2f366e74764329e49dccf"
  else
    odie "macOS x86_64 (Intel) is not supported via prebuilt binaries. Please install with --HEAD to build from source."
  end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/FrantaNautilus/uwiki/releases/download/v#{version}/uwiki-v#{version}-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "c6d8b2fb747e9c5e1c93affd3e2b796dd3b9cafe69bbde297ae089366a33eca1"
    else
      url "https://github.com/FrantaNautilus/uwiki/releases/download/v#{version}/uwiki-v#{version}-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "262fd5de08601f341478e6be2c694bea2bbe9892c3e5e7a7e1ad8e46afc79ead"
    end
  end

  head do
    url "https://github.com/FrantaNautilus/uwiki.git", branch: "main"
    depends_on "rust" => :build
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args
    else
      bin.install "uwiki"
    end

    # Generate shell completions (bash, zsh, fish, etc.)
    generate_completions_from_executable(bin/"uwiki", "completions")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/uwiki --version")

    (testpath/"test.md").write "# Example\n\n[[missing-link]]\n"
    output = shell_output("#{bin}/uwiki lint")
    assert_match "broken_links", output
    assert_match "missing-link", output
  end
end
