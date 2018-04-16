require 'test_helper'
require 'tilt'

begin
  require 'tilt/creole'

  class CreoleTemplateTest < Minitest::Test
    test "is registered for '.creole' files" do
      assert_equal Tilt::CreoleTemplate, Tilt['test.creole']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::CreoleTemplate.new { |t| "= Hello World!" }
      assert_equal "<h1>Hello World!</h1>", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::CreoleTemplate.new { |t| "= Hello World!" }
      3.times { assert_equal "<h1>Hello World!</h1>", template.render }
    end
  end
rescue LoadError
  warn "Tilt::CreoleTemplate (disabled)"
end
