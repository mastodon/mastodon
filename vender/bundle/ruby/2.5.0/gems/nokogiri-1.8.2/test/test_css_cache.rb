require "helper"

class TestCssCache < Nokogiri::TestCase

  def setup
    super
    @css = "a1 > b2 > c3"
    @parse_result = Nokogiri::CSS.parse(@css)
    @to_xpath_result = @parse_result.map(&:to_xpath)
    Nokogiri::CSS::Parser.class_eval do
      class << @cache
        alias :old_bracket :[]
        attr_reader :count
        def [](key)
          @count ||= 0
          @count += 1
          old_bracket(key)
        end
      end
    end
    assert Nokogiri::CSS::Parser.cache_on?
  end

  def teardown
    Nokogiri::CSS::Parser.clear_cache
    Nokogiri::CSS::Parser.set_cache true
  end

  [ false, true ].each do |cache_setting|
    define_method "test_css_cache_#{cache_setting ? "true" : "false"}" do
      times = cache_setting ? 4 : nil

      Nokogiri::CSS::Parser.set_cache cache_setting

      Nokogiri::CSS.xpath_for(@css)
      Nokogiri::CSS.xpath_for(@css)
      Nokogiri::CSS::Parser.new.xpath_for(@css)
      Nokogiri::CSS::Parser.new.xpath_for(@css)

      assert_equal(times, Nokogiri::CSS::Parser.class_eval { @cache.count })
    end
  end


end
