require 'test_helper'
require 'tilt'

begin
  require 'tilt/livescript'

  class LiveScriptTemplateTest < Minitest::Test
    setup do
      @code_without_variables = "puts 'Hello, World!'\n"
      @renderer = Tilt::LiveScriptTemplate
    end

    test "compiles and evaluates the template on #render" do
      template = @renderer.new { |t| @code_without_variables }
      assert_match "puts('Hello, World!');", template.render
    end

    test "can be rendered more than once" do
      template = @renderer.new { |t| @code_without_variables }
      3.times { assert_match "puts('Hello, World!');", template.render }
    end

    test "supports bare-option" do
      template = @renderer.new(:bare => false) { |t| @code_without_variables }
      assert_match "function", template.render

      template = @renderer.new(:bare => true) { |t| @code_without_variables }
      refute_match "function", template.render
    end

    test "is registered for '.ls' files" do
      assert_equal @renderer, Tilt['test.ls']
    end
  end
rescue LoadError
  warn "Tilt::LiveScriptTemplate (disabled)"
end
