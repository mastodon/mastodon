require "test_helper"

class CommandTest < Minitest::Test
  def test_compile_command_returns_success_status_when_stale
    Webpacker.compiler.stub :stale?, true do
      Webpacker.compiler.stub :run_webpack, true do
        assert_equal true, Webpacker.commands.compile
      end
    end
  end

  def test_compile_command_returns_success_status_when_fresh
    Webpacker.compiler.stub :stale?, false do
      Webpacker.compiler.stub :run_webpack, true do
        assert_equal true, Webpacker.commands.compile
      end
    end
  end

  def test_compile_command_returns_failure_status_when_stale
    Webpacker.compiler.stub :stale?, true do
      Webpacker.compiler.stub :run_webpack, false do
        assert_equal false, Webpacker.commands.compile
      end
    end
  end
end
