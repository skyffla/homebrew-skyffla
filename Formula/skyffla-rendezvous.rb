class SkyfflaRendezvous < Formula
  desc "Skyffla rendezvous server"
  homepage "https://github.com/skyffla/skyffla"
  version "0.1.8"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.8/skyffla-v0.1.8-aarch64-apple-darwin.tar.gz"
      sha256 "44b632c29c6153dc42c59ef4dcd568c0510950ecf83f1678f335cb5992c722d2"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.8/skyffla-v0.1.8-x86_64-apple-darwin.tar.gz"
      sha256 "f834475da6c363830594f454092aadc100d84df3fd8a36ca78cbe95f99649f18"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.8/skyffla-v0.1.8-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "bd623591c5d6a62995b5321df0d01116c2eb486fd3cb18b556764fa371c8aa85"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.8/skyffla-v0.1.8-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "f90a314c5ad11e6cb8b54da45318f4b9e8ecca6299cabf8c108bacb660eac1ce"
    end
  end

  def install
    bin.install "skyffla-rendezvous"
    prefix.install_metafiles
  end

  test do
    if "skyffla-rendezvous" == "skyffla"
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
