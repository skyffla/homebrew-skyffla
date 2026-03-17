class SkyfflaRendezvous < Formula
  desc "Skyffla rendezvous server"
  homepage "https://github.com/skyffla/skyffla"
  version "1.2.0"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.2.0/skyffla-v1.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "03985d1069ebd0fcf84ef3b06ab4fce7e4cb7d7ce508e7c131210544c7d71fea"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.2.0/skyffla-v1.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "e1852e8306665769949f19d52f5277197714728ffd5fe78625902207567fa12d"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.2.0/skyffla-v1.2.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "0f2480b2c8a8679c534db3bd142a1a2af03dce3e75ad13b1ffdcc650cf4b1e15"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.2.0/skyffla-v1.2.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "030131e7d5c6e5128f4e01638b571e5a7b74c2ea5265b9df4b81d7df9b4cfc13"
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
