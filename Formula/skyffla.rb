class Skyffla < Formula
  desc "CLI FIRST P2P FOR THE AGENTIC ERA"
  homepage "https://github.com/skyffla/skyffla"
  version "0.1.7"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.7/skyffla-v0.1.7-aarch64-apple-darwin.tar.gz"
      sha256 "46567c7bd0a23b63b55b47211b13fc730777b951d49d5e93246389a27744fa57"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.7/skyffla-v0.1.7-x86_64-apple-darwin.tar.gz"
      sha256 "92f0e688d624d85a964ab1e7d9fba670442e262a196d064c87578f9ba8afc1c7"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.7/skyffla-v0.1.7-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "04d26e6b3c0235158d20061ccb3c13cf87449f62ee61ffe63d170dee9e34d97d"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.7/skyffla-v0.1.7-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "1dd071faae8cd29ede5c88257be4338597c8a204baa3c06c318291138b1d27a8"
    end
  end

  def install
    bin.install "skyffla"
    prefix.install_metafiles
  end

  test do
    if "skyffla" == "skyffla"
      assert_match "Usage:", shell_output("#{bin}/skyffla --help")
    else
      port = free_port
      db_path = testpath/"skyffla-rendezvous.db"
      pid = fork do
        ENV["SKYFFLA_RENDEZVOUS_ADDR"] = "127.0.0.1:#{port}"
        ENV["SKYFFLA_RENDEZVOUS_DB_PATH"] = db_path.to_s
        exec bin/"skyffla-rendezvous"
      end

      begin
        sleep 2
        assert_match "ok", shell_output("curl -fsS http://127.0.0.1:#{port}/health")
      ensure
        begin
          Process.kill("TERM", pid)
        rescue Errno::ESRCH
          nil
        end
        Process.wait(pid)
      end
    end
  end
end
