class SkyfflaRendezvous < Formula
  desc "Skyffla rendezvous server"
  homepage "https://github.com/skyffla/skyffla"
  version "1.0.0"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.0.0/skyffla-v1.0.0-aarch64-apple-darwin.tar.gz"
      sha256 "b88be0532754d3ab293694cce8980efb07c7fbed1fe0be5fa6d304b2036ee765"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.0.0/skyffla-v1.0.0-x86_64-apple-darwin.tar.gz"
      sha256 "daa7429f341af89edf5983fd18868878792cf2873e201e682c842c24dbc3f934"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.0.0/skyffla-v1.0.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "379428080c44d3518f1991865cf196a15121ed875083f9840a2f032e6d593efd"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.0.0/skyffla-v1.0.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "d010572bfa1738b9251e5632544e6cf0569485ec8a7acbaa15745e540803e33f"
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
