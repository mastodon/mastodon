require 'test_helper'
require 'tilt'

class TiltTest < Minitest::Test
  class MockTemplate
    attr_reader :args, :block
    def initialize(*args, &block)
      @args = args
      @block = block
    end
  end

  test "registering template implementation classes by file extension" do
    Tilt.register(MockTemplate, 'mock')
  end

  test "an extension is registered if explicit handle is found" do
    Tilt.register(MockTemplate, 'mock')
    assert Tilt.registered?('mock')
  end

  test "registering template classes by symbol file extension" do
    Tilt.register(MockTemplate, :mock)
  end

  test "looking up template classes by exact file extension" do
    Tilt.register(MockTemplate, 'mock')
    impl = Tilt['mock']
    assert_equal MockTemplate, impl
  end

  test "looking up template classes by implicit file extension" do
    Tilt.register(MockTemplate, 'mock')
    impl = Tilt['.mock']
    assert_equal MockTemplate, impl
  end

  test "looking up template classes with multiple file extensions" do
    Tilt.register(MockTemplate, 'mock')
    impl = Tilt['index.html.mock']
    assert_equal MockTemplate, impl
  end

  test "looking up template classes by file name" do
    Tilt.register(MockTemplate, 'mock')
    impl = Tilt['templates/test.mock']
    assert_equal MockTemplate, impl
  end

  test "looking up non-existant template class" do
    assert_nil Tilt['none']
  end

  test "creating new template instance with a filename" do
    Tilt.register(MockTemplate, 'mock')
    template = Tilt.new('foo.mock', 1, :key => 'val') { 'Hello World!' }
    assert_equal ['foo.mock', 1, {:key => 'val'}], template.args
    assert_equal 'Hello World!', template.block.call
  end
end
