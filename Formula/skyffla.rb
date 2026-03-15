class Skyffla < Formula
  desc "CLI FIRST P2P FOR THE AGENTIC ERA"
  homepage "https://github.com/skyffla/skyffla"
  version "1.1.1"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.1/skyffla-v1.1.1-aarch64-apple-darwin.tar.gz"
      sha256 "54209d1ede9c28da71acf112d953b5a46db25ce0718ad2f8e8e3db366062c145"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.1/skyffla-v1.1.1-x86_64-apple-darwin.tar.gz"
      sha256 "df5cb1c7124d4a6d3c2a67fa6213d0db7f0aa3479edf90d11e3a53682d5b77eb"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.1/skyffla-v1.1.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "050634dbdd39a372425cd5b8f1ef6ff94d86e47502f2080cd9fd1f1e7930a9d8"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v1.1.1/skyffla-v1.1.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "cf7ac245cb2109e529cc8aa558d09ed2390d079cb1e973881bdec1c59074faa6"
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
