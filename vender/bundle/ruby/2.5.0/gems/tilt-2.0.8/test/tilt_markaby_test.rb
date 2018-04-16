require 'test_helper'
require 'tilt'

begin
  require 'tilt/markaby'

  class MarkabyTiltTest <  Minitest::Test
    def setup
      @block = lambda do |t|
        File.read(File.dirname(__FILE__) + "/#{t.file}")
      end
    end

    test "should be able to render a markaby template with static html" do
      tilt = Tilt::MarkabyTemplate.new("markaby/markaby.mab", &@block)
      assert_equal "hello from markaby!", tilt.render
    end

    test "should use the contents of the template" do
      tilt = ::Tilt::MarkabyTemplate.new("markaby/markaby_other_static.mab", &@block)
      assert_equal "_why?", tilt.render
    end

    test "should render from a string (given as data)" do
      tilt = ::Tilt::MarkabyTemplate.new { "html do; end" }
      assert_equal "<html></html>", tilt.render
    end

    test "can be rendered more than once" do
      tilt = ::Tilt::MarkabyTemplate.new { "html do; end" }
      3.times { assert_equal "<html></html>", tilt.render }
    end

    test "should evaluate a template file in the scope given" do
      scope = Object.new
      def scope.foo
        "bar"
      end

      tilt = ::Tilt::MarkabyTemplate.new("markaby/scope.mab", &@block)
      assert_equal "<li>bar</li>", tilt.render(scope)
    end

    test "should pass locals to the template" do
      tilt = ::Tilt::MarkabyTemplate.new("markaby/locals.mab", &@block)
      assert_equal "<li>bar</li>", tilt.render(Object.new, { :foo => "bar" })
    end

    test "should yield to the block given" do
      tilt = ::Tilt::MarkabyTemplate.new("markaby/yielding.mab", &@block)
      eval_scope = Markaby::Builder.new

      output = tilt.render(Object.new, {}) do
        text("Joe")
      end

      assert_equal "Hey Joe", output
    end

    test "should be able to render two templates in a row" do
      tilt = ::Tilt::MarkabyTemplate.new("markaby/render_twice.mab", &@block)

      assert_equal "foo", tilt.render
      assert_equal "foo", tilt.render
    end

    test "should retrieve a Tilt::MarkabyTemplate when calling Tilt['hello.mab']" do
      assert_equal Tilt::MarkabyTemplate, ::Tilt['./markaby/markaby.mab']
    end

    test "should return a new instance of the implementation class (when calling Tilt.new)" do
      assert ::Tilt.new(File.dirname(__FILE__) + "/markaby/markaby.mab").kind_of?(Tilt::MarkabyTemplate)
    end

    test "should be able to evaluate block style templates" do
      tilt = Tilt::MarkabyTemplate.new { |t| lambda { h1 "Hello World!" }}
      assert_equal "<h1>Hello World!</h1>", tilt.render
    end

    test "should pass locals to block style templates" do
      tilt = Tilt::MarkabyTemplate.new { |t| lambda { h1 "Hello #{name}!" }}
      assert_equal "<h1>Hello _why!</h1>", tilt.render(nil, :name => "_why")
    end
  end

rescue LoadError
  warn "Tilt::MarkabyTemplate (disabled)"
end
