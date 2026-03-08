class Skyffla < Formula
  desc "Terminal-native peer communication tool"
  homepage "https://github.com/skyffla/skyffla"
  version "0.1.5"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.5/skyffla-v0.1.5-aarch64-apple-darwin.tar.gz"
      sha256 "bb83b85bc9af3a8794bfb7c1f1e58ebca03b2fecd7f858429296781112804efb"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.5/skyffla-v0.1.5-x86_64-apple-darwin.tar.gz"
      sha256 "16f928a061b9dbf012278f18868e2852440b9959b219d0419e4c8713fb2fe2f7"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.5/skyffla-v0.1.5-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "b085da975fe6f0375a70965f2be40c3a4663584db36fb1cf9a93efb5d68d68ea"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.5/skyffla-v0.1.5-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "6313fb1eb0cd99a3b5743f1632cf2a7624ede3bf1f962a613f6c08a233101173"
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
