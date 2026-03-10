class SkyfflaRendezvous < Formula
  desc "Skyffla rendezvous server"
  homepage "https://github.com/skyffla/skyffla"
  version "0.2.0"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.2.0/skyffla-v0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "2bc940adf15647102a91b6a1268f9692497b12bee698097438943c06e9d11597"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.2.0/skyffla-v0.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "67c5cc606fff27b90080fcbbee74d02fa635f636ebb7ac3720a668a5ecb65e06"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.2.0/skyffla-v0.2.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "0ee8e9034de792fe4b23f2842ec20ee2b7c695d23a12d8eb2ee74f2d37d23ad0"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.2.0/skyffla-v0.2.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "cab1b23736de47c9a0a9bf43f1688a45a3ca22088ac85a4ef2355b20fc0a5518"
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
