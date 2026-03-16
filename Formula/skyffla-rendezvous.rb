class SkyfflaRendezvous < Formula
  desc "Skyffla rendezvous server"
  homepage "https://github.com/skyffla/skyffla"
  version "1.1.4"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.4/skyffla-v1.1.4-aarch64-apple-darwin.tar.gz"
      sha256 "a972cdde3d9092e45f6546245860cc1d03319a8550a59fa1477a1167127ff5b4"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.4/skyffla-v1.1.4-x86_64-apple-darwin.tar.gz"
      sha256 "2d67d8e5964be8040bdeab95ab01734ed5c3daeb9e2f488e3de05abcdabd0dcd"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.4/skyffla-v1.1.4-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "0dd1c6d201ad74cf7da0a9e03c84256fd22d01cc36da3288d8563d192f3d41cd"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.4/skyffla-v1.1.4-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "345ed0df5eb90295fa624184c06cddb0d91e436be76dbe6bfe6baa8545140c3b"
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
