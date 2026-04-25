class Skyffla < Formula
  desc "CLI FIRST P2P FOR THE AGENTIC ERA"
  homepage "https://github.com/skyffla/skyffla"
  version "2.1.2"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v2.1.2/skyffla-v2.1.2-aarch64-apple-darwin.tar.gz"
      sha256 "143b3659ee01a785d11d1a57093c35b1775406073fdcb5ee72a966a3e944cf8a"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v2.1.2/skyffla-v2.1.2-x86_64-apple-darwin.tar.gz"
      sha256 "424b333fe86ba205ff395eb781eeaa44868d6cb1b7f41d5cfd509e15ec048558"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v2.1.2/skyffla-v2.1.2-aarch64-unknown-linux-musl.tar.gz"
      sha256 "bdd5c26257ada8628f3600325a27b1069c3631fac21f276d82ee8da3540685e8"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v2.1.2/skyffla-v2.1.2-x86_64-unknown-linux-musl.tar.gz"
      sha256 "b96ab4d78f71ca62350da0f280b13ac8471262a02f853b0c50a86de4b9575ed2"
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
