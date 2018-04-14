require "test_helper"

class DevServerTest < Webpacker::Test
  def test_running?
    refute Webpacker.dev_server.running?
  end

  def test_host
    with_rails_env("development") do
      assert_equal Webpacker.dev_server.host, "localhost"
    end
  end

  def test_port
    with_rails_env("development") do
      assert_equal Webpacker.dev_server.port, 3035
    end
  end

  def test_https?
    with_rails_env("development") do
      assert_equal Webpacker.dev_server.https?, false
    end
  end
end
