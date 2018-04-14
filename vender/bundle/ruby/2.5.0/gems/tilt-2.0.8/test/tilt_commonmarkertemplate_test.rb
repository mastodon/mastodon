require 'test_helper'
require 'tilt'

begin
  require 'tilt/commonmarker'

  class CommonMarkerTemplateTest < Minitest::Test
    test "preparing and evaluating templates on #render" do
      template = Tilt::CommonMarkerTemplate.new { |t| "# Hello World!" }
      assert_equal "<h1>Hello World!</h1>\n", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::CommonMarkerTemplate.new { |t| "# Hello World!" }
      3.times { assert_equal "<h1>Hello World!</h1>\n", template.render }
    end
  end
rescue LoadError
  warn "Tilt::CommonMarkerTemplate (disabled)"
end
