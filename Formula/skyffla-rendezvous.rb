class SkyfflaRendezvous < Formula
  desc "Skyffla rendezvous server"
  homepage "https://github.com/skyffla/skyffla"
  version "2.2.1"
  license "MIT"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v2.2.1/skyffla-v2.2.1-aarch64-apple-darwin.tar.gz"
      sha256 "0a9b565be1f32cb6f5aa95483bd02201d0920f892970a5087e4443877c0bea32"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v2.2.1/skyffla-v2.2.1-x86_64-apple-darwin.tar.gz"
      sha256 "3858c78b8521bd80663a180300440ae7631991dd1c692bae4f2d9f6974d94dea"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/skyffla/skyffla/releases/download/v2.2.1/skyffla-v2.2.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "6e0ae15b8d77dc65b50cdfd99a8ca8c4bcde43b6726926aca88ec3fb59627647"
    else
      url "https://github.com/skyffla/skyffla/releases/download/v2.2.1/skyffla-v2.2.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "6de70b4967606c2bee56a0d98843f76a631c8499afbd3e0aa7b453b1b5391548"
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
