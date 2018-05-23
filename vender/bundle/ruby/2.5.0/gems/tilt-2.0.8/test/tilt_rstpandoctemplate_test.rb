require 'test_helper'
require 'tilt'

begin
  require 'tilt/rst-pandoc'

  class RstPandocTemplateTest < Minitest::Test
    test "is registered for '.rst' files" do
      assert_equal Tilt::RstPandocTemplate, Tilt['test.rst']
    end

    test "compiles and evaluates the template on #render" do
      template = Tilt::RstPandocTemplate.new { |t| "Hello World!\n============" }
      assert_equal "<h1 id=\"hello-world\">Hello World!</h1>", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::RstPandocTemplate.new { |t| "Hello World!\n============" }
      3.times do
        assert_equal "<h1 id=\"hello-world\">Hello World!</h1>", template.render
      end
    end

    test "doens't use markdown options" do
      template = Tilt::RstPandocTemplate.new(:escape_html => true) { |t| "HELLO <blink>WORLD</blink>" }
      err = assert_raises(RuntimeError) { template.render }
      assert_match %r(pandoc: unrecognized option `--escape-html), err.message
    end
  end
rescue LoadError => boom
  warn "Tilt::RstPandocTemplate (disabled) [#{boom}]"
end
