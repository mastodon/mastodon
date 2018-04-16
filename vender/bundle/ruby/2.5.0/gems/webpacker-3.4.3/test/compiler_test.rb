require "test_helper"

class CompilerTest < Minitest::Test
  def setup
    Webpacker.compiler.send(:compilation_digest_path).tap do |path|
      path.delete if path.exist?
    end
  end

  def test_custom_environment_variables
    assert Webpacker.compiler.send(:webpack_env)["FOO"] == nil
    Webpacker.compiler.env["FOO"] = "BAR"
    assert Webpacker.compiler.send(:webpack_env)["FOO"] == "BAR"
  end

  def test_default_watched_paths
    assert_equal Webpacker.compiler.send(:default_watched_paths), [
      "app/assets/**/*",
      "/etc/yarn/**/*",
      "test/test_app/app/javascript/**/*",
      "yarn.lock",
      "package.json",
      "config/webpack/**/*"
    ]
  end

  def test_freshness
    assert Webpacker.compiler.stale?
    assert !Webpacker.compiler.fresh?
  end

  def test_compilation_digest_path
    assert Webpacker.compiler.send(:compilation_digest_path).to_s.ends_with?(Webpacker.env)
  end
end
