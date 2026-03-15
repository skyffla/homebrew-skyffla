class Skyffla < Formula
  desc "CLI FIRST P2P FOR THE AGENTIC ERA"
  homepage "https://github.com/skyffla/skyffla"
  version "1.1.0"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.0/skyffla-v1.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "a3adae5c229fd56733002d37138590a9d7bcf2ed25d70dcee873fc753df8c558"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.0/skyffla-v1.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "c02714623759410dfa5204eb0486eb767bc59658d6a992ccddac99a04cafe394"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.0/skyffla-v1.1.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "57c5f350ca288c2689bcedb80872ef953fb1efab9147764280ca6ab405ccd60a"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.0/skyffla-v1.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "61b1902e6a0e662ecdbe6753a227adab0ef039fa0a28e3bf530ba308e746f408"
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
