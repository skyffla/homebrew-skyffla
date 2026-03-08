class SkyfflaRendezvous < Formula
  desc "Skyffla rendezvous server"
  homepage "https://github.com/skyffla/skyffla"
  version "0.1.3"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.3/skyffla-v0.1.3-aarch64-apple-darwin.tar.gz"
      sha256 "b73bc38b1626c06eb60e79803725a365e6a128410d12955675cabef1edb938f6"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.3/skyffla-v0.1.3-x86_64-apple-darwin.tar.gz"
      sha256 "a1777172e72a79665e97d330a49a9104d38afab3bf0ba25f5de68fe26dbfa046"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.3/skyffla-v0.1.3-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "8e87775f20cb1c0dc9c78281d0d082ea95c0bedfb7d764c2da3b57ba3a18762a"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.3/skyffla-v0.1.3-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "77183fdf60bff6ab5a493cb95d77ce629b82a96756368b6620a7e9a1af2cf08b"
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
