class Skyffla < Formula
  desc "Terminal-native peer communication tool"
  homepage "https://github.com/skyffla/skyffla"
  version "0.1.2"
  license "MIT"

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/skyffla/skyffla/releases/download/v0.1.2/skyffla-v0.1.2-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "4aad160146af886017f290d686056792215ef3cb7a2fc8d7f99dac3990d31a23"
  else
    odie "This formula currently ships x86_64 Linux artifacts only."
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
