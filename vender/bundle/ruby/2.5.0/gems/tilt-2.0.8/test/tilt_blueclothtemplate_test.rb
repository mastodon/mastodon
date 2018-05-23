require 'test_helper'
require 'tilt'

begin
  require 'tilt/bluecloth'

  class BlueClothTemplateTest < Minitest::Test
    test "preparing and evaluating templates on #render" do
      template = Tilt::BlueClothTemplate.new { |t| "# Hello World!" }
      assert_equal "<h1>Hello World!</h1>", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::BlueClothTemplate.new { |t| "# Hello World!" }
      3.times { assert_equal "<h1>Hello World!</h1>", template.render }
    end

    test "smartypants when :smart is set" do
      template = Tilt::BlueClothTemplate.new(:smartypants => true) { |t|
        "OKAY -- 'Smarty Pants'" }
      assert_equal "<p>OKAY &mdash; &lsquo;Smarty Pants&rsquo;</p>",
        template.render
    end

    test "stripping HTML when :filter_html is set" do
      template = Tilt::BlueClothTemplate.new(:escape_html => true) { |t|
        "HELLO <blink>WORLD</blink>" }
      assert_equal "<p>HELLO &lt;blink>WORLD&lt;/blink></p>", template.render
    end
  end
rescue LoadError
  warn "Tilt::BlueClothTemplate (disabled)"
end
