class SkyfflaRendezvous < Formula
  desc "Skyffla rendezvous server"
  homepage "https://github.com/skyffla/skyffla"
  version "0.1.6"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.6/skyffla-v0.1.6-aarch64-apple-darwin.tar.gz"
      sha256 "1008ab09fd5de6fe7c3352973cbcd5637d2e1a331034da105391420b81ae0fc3"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.6/skyffla-v0.1.6-x86_64-apple-darwin.tar.gz"
      sha256 "990a7748327dcfeceb9799af5a3e14f9a7e4a41510e1d8456ee35717fbb5fc0c"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.6/skyffla-v0.1.6-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "ca3238a3993a72f7d2dde5340a99d32e18a08e504e26426046a2274d2ba94947"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.6/skyffla-v0.1.6-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "a17ef4891cda49bc211a9644cb5a759eb8d272777e6f12262bcd32566504da92"
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
