require 'test_helper'
require 'tilt'

begin
  require 'tilt/rdiscount'

  class RDiscountTemplateTest < Minitest::Test
    test "registered above BlueCloth" do
      %w[md mkd markdown].each do |ext|
        lazy = Tilt.lazy_map[ext]
        rdis_idx = lazy.index { |klass, file| klass == 'Tilt::RDiscountTemplate' }
        blue_idx = lazy.index { |klass, file| klass == 'Tilt::BlueClothTemplate' }
        assert rdis_idx < blue_idx,
          "#{rdis_idx} should be lower than #{blue_idx}"
      end
    end

    test "preparing and evaluating templates on #render" do
      template = Tilt::RDiscountTemplate.new { |t| "# Hello World!" }
      assert_equal "<h1>Hello World!</h1>\n", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::RDiscountTemplate.new { |t| "# Hello World!" }
      3.times { assert_equal "<h1>Hello World!</h1>\n", template.render }
    end

    test "smartypants when :smart is set" do
      template = Tilt::RDiscountTemplate.new(:smart => true) { |t|
        "OKAY -- 'Smarty Pants'" }
      assert_equal "<p>OKAY &ndash; &lsquo;Smarty Pants&rsquo;</p>\n",
        template.render
    end

    test "stripping HTML when :filter_html is set" do
      template = Tilt::RDiscountTemplate.new(:filter_html => true) { |t|
        "HELLO <blink>WORLD</blink>" }
      assert_equal "<p>HELLO &lt;blink>WORLD&lt;/blink></p>\n", template.render
    end
  end
rescue LoadError
  warn "Tilt::RDiscountTemplate (disabled)"
end
