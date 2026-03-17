class SkyfflaRendezvous < Formula
  desc "Skyffla rendezvous server"
  homepage "https://github.com/skyffla/skyffla"
  version "1.2.1"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.2.1/skyffla-v1.2.1-aarch64-apple-darwin.tar.gz"
      sha256 "375f68811129be76e7daa9a1eab9fd2f516591207556d9f576590cb60a444038"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.2.1/skyffla-v1.2.1-x86_64-apple-darwin.tar.gz"
      sha256 "b18fa3bf82c26b8d44ac52f6ee68bca807329e0a521946dc90c810cf1011d9eb"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.2.1/skyffla-v1.2.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "bfe5269681afa5843cced9128dfb904ced80cc439c8452468868b8b023f2ef7d"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.2.1/skyffla-v1.2.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "6748f196a5998474d2b2debe05bc5cdf01eb0f02c9453f8905e6db52db56e3e5"
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
