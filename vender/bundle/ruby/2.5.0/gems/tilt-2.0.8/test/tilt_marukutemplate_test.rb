require 'test_helper'
require 'tilt'

begin
  require 'tilt/maruku'

  class MarukuTemplateTest < Minitest::Test
    test "registered below Kramdown" do
      %w[md mkd markdown].each do |ext|
        lazy = Tilt.lazy_map[ext]
        kram_idx = lazy.index { |klass, file| klass == 'Tilt::KramdownTemplate' }
        maru_idx = lazy.index { |klass, file| klass == 'Tilt::MarukuTemplate' }
        assert maru_idx > kram_idx,
          "#{maru_idx} should be higher than #{kram_idx}"
      end
    end

    test "preparing and evaluating templates on #render" do
      template = Tilt::MarukuTemplate.new { |t| "# Hello World!" }
      assert_equal "<h1 id=\"hello_world\">Hello World!</h1>", template.render.strip
    end

    test "can be rendered more than once" do
      template = Tilt::MarukuTemplate.new { |t| "# Hello World!" }
      3.times { assert_equal "<h1 id=\"hello_world\">Hello World!</h1>", template.render.strip }
    end

    test "removes HTML when :filter_html is set" do
      template = Tilt::MarukuTemplate.new(:filter_html => true) { |t|
        "HELLO <blink>WORLD</blink>" }
      assert_equal "<p>HELLO</p>", template.render.strip
    end
  end
rescue LoadError
  warn "Tilt::MarukuTemplate (disabled)"
end
