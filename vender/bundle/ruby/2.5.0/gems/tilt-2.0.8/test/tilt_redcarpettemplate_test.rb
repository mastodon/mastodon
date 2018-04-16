require 'test_helper'
require 'tilt'

begin
  require 'tilt/redcarpet'

  class RedcarpetTemplateTest < Minitest::Test
    test "registered above BlueCloth" do
      %w[md mkd markdown].each do |ext|
        lazy = Tilt.lazy_map[ext]
        blue_idx = lazy.index { |klass, file| klass == 'Tilt::BlueClothTemplate' }
        redc_idx = lazy.index { |klass, file| klass == 'Tilt::RedcarpetTemplate' }
        assert redc_idx < blue_idx,
          "#{redc_idx} should be lower than #{blue_idx}"
      end
    end

    test "registered above RDiscount" do
      %w[md mkd markdown].each do |ext|
        lazy = Tilt.lazy_map[ext]
        rdis_idx = lazy.index { |klass, file| klass == 'Tilt::RDiscountTemplate' }
        redc_idx = lazy.index { |klass, file| klass == 'Tilt::RedcarpetTemplate' }
        assert redc_idx < rdis_idx,
          "#{redc_idx} should be lower than #{rdis_idx}"
      end
    end

    test "preparing and evaluating templates on #render" do
      template = Tilt::RedcarpetTemplate.new { |t| "# Hello World!" }
      assert_equal "<h1>Hello World!</h1>\n", template.render
    end

    test "can be rendered more than once" do
      template = Tilt::RedcarpetTemplate.new { |t| "# Hello World!" }
      3.times { assert_equal "<h1>Hello World!</h1>\n", template.render }
    end

    test "smartypants when :smart is set" do
      template = Tilt::RedcarpetTemplate.new(:smartypants => true) { |t|
        "OKAY -- 'Smarty Pants'" }
      assert_match %r!<p>OKAY &ndash; (&#39;|&lsquo;)Smarty Pants(&#39;|&rsquo;)<\/p>!,
        template.render
    end

    test "smartypants with a rendererer instance" do
      template = Tilt::RedcarpetTemplate.new(:renderer => Redcarpet::Render::HTML.new(:hard_wrap => true), :smartypants => true) { |t|
        "OKAY -- 'Smarty Pants'" }
      assert_match %r!<p>OKAY &ndash; (&#39;|&lsquo;)Smarty Pants(&#39;|&rsquo;)<\/p>!,
        template.render
    end
  end
rescue LoadError
  warn "Tilt::RedcarpetTemplate (disabled)"
end
