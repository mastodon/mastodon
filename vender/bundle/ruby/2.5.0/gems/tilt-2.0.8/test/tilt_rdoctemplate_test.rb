require 'test_helper'
require 'tilt'

begin
  require 'tilt/rdoc'
  class RDocTemplateTest < Minitest::Test
    test "is registered for '.rdoc' files" do
      assert_equal Tilt::RDocTemplate, Tilt['test.rdoc']
    end

    test "preparing and evaluating the template with #render" do
      template = Tilt::RDocTemplate.new { |t| "= Hello World!" }
      result = template.render.strip
      assert_match %r(<h1), result
      assert_match %r(>Hello World!<), result
    end

    test "can be rendered more than once" do
      template = Tilt::RDocTemplate.new { |t| "= Hello World!" }
      3.times do
        result = template.render.strip
        assert_match %r(<h1), result
        assert_match %r(>Hello World!<), result
      end
    end
  end
rescue LoadError => boom
  warn "Tilt::RDocTemplate (disabled) [#{boom}]"
end
