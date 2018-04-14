require 'test_helper'
require 'tilt'

begin
  require 'tilt/babel'

  class BabelTemplateTest < Minitest::Test
    test "registered for '.es6' files" do
      assert_equal Tilt::BabelTemplate, Tilt['es6']
    end

    test "registered for '.babel' files" do
      assert_equal Tilt::BabelTemplate, Tilt['babel']
    end

    test "registered for '.jsx' files" do
      assert_equal Tilt::BabelTemplate, Tilt['jsx']
    end

    test "basic ES6 features" do
      template = Tilt::BabelTemplate.new { "square = (x) => x * x" }
      assert_match "function", template.render
    end

    test "JSX support" do
      template = Tilt::BabelTemplate.new { "<Awesome ness={true} />" }
      assert_match "React.createElement", template.render
    end
  end
rescue LoadError => boom
  warn "Tilt::BabelTemplate (disabled)"
end

