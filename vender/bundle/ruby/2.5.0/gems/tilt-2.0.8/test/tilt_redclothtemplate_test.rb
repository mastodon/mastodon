require 'test_helper'
require 'tilt'

begin
  require 'tilt/redcloth'

  class RedClothTemplateTest < Minitest::Test
    test "is registered for '.textile' files" do
      assert_equal Tilt::RedClothTemplate, Tilt['test.textile']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::RedClothTemplate.new { |t| "h1. Hello World!" }
      assert_equal "<h1>Hello World!</h1>", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::RedClothTemplate.new { |t| "h1. Hello World!" }
      3.times { assert_equal "<h1>Hello World!</h1>", template.render }
    end

    test "ignores unknown options" do
      template = Tilt::RedClothTemplate.new(:foo => "bar") { |t| "h1. Hello World!" }
      3.times { assert_equal "<h1>Hello World!</h1>", template.render }
    end

    test "passes in RedCloth options" do
      template = Tilt::RedClothTemplate.new { |t| "Hard breaks are\ninserted by default." }
      assert_equal "<p>Hard breaks are<br />\ninserted by default.</p>", template.render
      template = Tilt::RedClothTemplate.new(:hard_breaks => false) { |t| "But they can be\nturned off." }
      assert_equal "<p>But they can be\nturned off.</p>", template.render
    end
  end
rescue LoadError
  warn "Tilt::RedClothTemplate (disabled)"
end
