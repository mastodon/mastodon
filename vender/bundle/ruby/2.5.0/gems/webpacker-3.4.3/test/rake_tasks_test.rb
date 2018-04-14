require "test_helper"

class RakeTasksTest < Minitest::Test
  def test_rake_tasks
    output = Dir.chdir(test_app_path) { `rake -T` }
    assert_includes output, "webpacker"
    assert_includes output, "webpacker:check_binstubs"
    assert_includes output, "webpacker:check_node"
    assert_includes output, "webpacker:check_yarn"
    assert_includes output, "webpacker:clobber"
    assert_includes output, "webpacker:compile"
    assert_includes output, "webpacker:install"
    assert_includes output, "webpacker:install:angular"
    assert_includes output, "webpacker:install:elm"
    assert_includes output, "webpacker:install:react"
    assert_includes output, "webpacker:install:vue"
    assert_includes output, "webpacker:verify_install"
  end

  def test_rake_task_webpacker_check_binstubs
    output = Dir.chdir(test_app_path) { `rake webpacker:check_binstubs 2>&1` }
    refute_includes output, "webpack binstubs not found."
  end

  private
    def test_app_path
      File.expand_path("test_app", __dir__)
    end
end
