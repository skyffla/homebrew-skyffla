class SkyfflaRendezvous < Formula
  desc "Skyffla rendezvous server"
  homepage "https://github.com/skyffla/skyffla"
  version "1.1.3"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.3/skyffla-v1.1.3-aarch64-apple-darwin.tar.gz"
      sha256 "fe7ad19298030326c8e7515e3b50a4df6f8bf7e8855a05edb57a27f962777d97"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.3/skyffla-v1.1.3-x86_64-apple-darwin.tar.gz"
      sha256 "75c26cb41b5ac515a2d41e801bb2bad5c6ecb1e11296d0cec44844e4931f89f2"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.3/skyffla-v1.1.3-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "9bb7b0ceab563826f67ca69a32a3c5dbda337c09446ed66842fda9f536a13190"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.3/skyffla-v1.1.3-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "2554d8081a97594f65d143631b41b603ca89b5cbdd6208098e6a931ece577653"
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
