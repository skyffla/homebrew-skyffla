class Skyffla < Formula
  desc "Terminal-native peer communication tool"
  homepage "https://github.com/skyffla/skyffla"
  version "0.1.0"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.0/skyffla-v0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "488f944ff68aa73dc02e6055c35a853df5c7865e12f28dacb6b68c7a829ef70c"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.0/skyffla-v0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "25ac5d1e856e3b9657ae6d68a529430fa807ec000d32419168dd2957c0f7cb6e"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.0/skyffla-v0.1.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "01f8987b4d7438fb9230cd9ae4ad197b78de8f04f62cbb39dbb7a8b24b5ad017"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v0.1.0/skyffla-v0.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "14efb8564490c014c3ba8f3e59fda21c9e8be96e687a468b02a01b7c9ae72564"
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
