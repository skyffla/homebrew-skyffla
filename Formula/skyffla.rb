class Skyffla < Formula
  desc "CLI FIRST P2P FOR THE AGENTIC ERA"
  homepage "https://github.com/skyffla/skyffla"
  version "2.0.0"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v2.0.0/skyffla-v2.0.0-aarch64-apple-darwin.tar.gz"
      sha256 "7bc3d5cdfbb64a5aaa30fd95b71825041d2df75ee6c3a1a6667cf045fbdcd185"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v2.0.0/skyffla-v2.0.0-x86_64-apple-darwin.tar.gz"
      sha256 "7638cca91ddf7e80464f10c35b9b79164831a2edaa6e74dd761ba9719a8ffe3e"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v2.0.0/skyffla-v2.0.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "359385d266c0cc4788836669521306717b59ab8448103dba4c721db6fe269bf6"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v2.0.0/skyffla-v2.0.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "afc7c8ffea2dee5fa21a9816923107a800a459276646cb079ef04f6a049ce2d0"
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
