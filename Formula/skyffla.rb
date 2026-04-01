class Skyffla < Formula
  desc "CLI FIRST P2P FOR THE AGENTIC ERA"
  homepage "https://github.com/skyffla/skyffla"
  version "2.1.0"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v2.1.0/skyffla-v2.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "f70ac83cfb0761303cb3526c0173998c0c36f2e58f28e14db126c4c2368dbfd6"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v2.1.0/skyffla-v2.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "2bbc622b36bd2901a25941c8ee0f29e3bca239a06718bc87282475cbe3870fa6"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v2.1.0/skyffla-v2.1.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d59726b9010b0bce78353c6ac815241a0f700074e33671b6bfa269ef4bbc35b4"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v2.1.0/skyffla-v2.1.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "3c1ef5fc2f408e6f31fac36ca331b3d07de17a3455364e652c09457586a279d1"
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
