class SkyfflaRendezvous < Formula
  desc "Skyffla rendezvous server"
  homepage "https://github.com/skyffla/skyffla"
  version "2.2.0"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v2.2.0/skyffla-v2.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "bf527f5c8a08f6e246c2c149687dcb04334bb5ee24400f026653875116101160"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v2.2.0/skyffla-v2.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "0527344567156d0e72149fc8dc10e640adf5ec1f893608dbe1194baa35ad0199"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v2.2.0/skyffla-v2.2.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "61b3e9b93c8050aeba10bae459c46ab4451a09a56012bdd331525842821786c2"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v2.2.0/skyffla-v2.2.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "f0271224c6f9516f352e3e7d049295d8f651f4a5949a04c262f864346adf331e"
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
