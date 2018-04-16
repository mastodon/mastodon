require 'minitest/autorun'

module Builder
  class Test < Minitest::Test
    alias :assert_raise :assert_raises
    alias :assert_not_nil :refute_nil

    def assert_nothing_raised
      yield
    end
  end
end
