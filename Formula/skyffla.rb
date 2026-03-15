class Skyffla < Formula
  desc "CLI FIRST P2P FOR THE AGENTIC ERA"
  homepage "https://github.com/skyffla/skyffla"
  version "1.1.2"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.2/skyffla-v1.1.2-aarch64-apple-darwin.tar.gz"
      sha256 "88bd232b69090941f013e4fdc749d37d30197a640d7d9e91e7326f0e2e3b2b17"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.2/skyffla-v1.1.2-x86_64-apple-darwin.tar.gz"
      sha256 "ef8f89a98ff2a3ec69af6bf27c988d96d734d256ca2224992db8dbbe10300f25"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.2/skyffla-v1.1.2-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "56f7a759544c5a18a5a2a4a2dba04369616696c3ae0201d63953b5c530a20cb4"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.2/skyffla-v1.1.2-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "38e8af046d05cc2b238ac8f64dd015d2b5779fdc6951c7171e74da65600fbed8"
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
