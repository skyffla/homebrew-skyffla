class SkyfflaRendezvous < Formula
  desc "Skyffla rendezvous server"
  homepage "https://github.com/skyffla/skyffla"
  version "2.1.1"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v2.1.1/skyffla-v2.1.1-aarch64-apple-darwin.tar.gz"
      sha256 "268a2219c5cb955c353f97cf167abff9bb786a32de2aa49fc1f4c4805ab82181"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v2.1.1/skyffla-v2.1.1-x86_64-apple-darwin.tar.gz"
      sha256 "575863b5c0242f3087bcd7a7118c495c3c3092880018a01c63dddca86f3025c9"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v2.1.1/skyffla-v2.1.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "f1ad391db2f3df9b6be9fa415227d019395daf20e4b7aec5e330cd420fb8ff2c"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v2.1.1/skyffla-v2.1.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "7c7ab9a2e5f290a20fe2a7c07b1a996c19e164f69f89c84aa67c3b8cf014d401"
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
