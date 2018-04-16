require "helper"

module Nokogiri
  module XML
    class TestParseOptions < Nokogiri::TestCase
      def test_new
        options = Nokogiri::XML::ParseOptions.new
        assert_equal 0, options.options
      end

      def test_to_i
        options = Nokogiri::XML::ParseOptions.new
        assert_equal 0, options.to_i
      end

      ParseOptions.constants.each do |constant|
        next if constant == 'STRICT'
        class_eval %{
          def test_predicate_#{constant.downcase}
            options = ParseOptions.new(ParseOptions::#{constant})
            assert options.#{constant.downcase}?

            assert ParseOptions.new.#{constant.downcase}.#{constant.downcase}?
          end
        }
      end

      def test_strict_noent
        options = ParseOptions.new.recover.noent
        assert !options.strict?
      end

      def test_new_with_argument
        options = Nokogiri::XML::ParseOptions.new 1 << 1
        assert_equal 1 << 1, options.options
      end

      def test_unsetting
        options = Nokogiri::XML::ParseOptions.new Nokogiri::XML::ParseOptions::DEFAULT_HTML
        assert options.nonet?
        assert options.recover?
        options.nononet.norecover
        assert ! options.nonet?
        assert ! options.recover?
        options.nonet.recover
        assert options.nonet?
        assert options.recover?
      end

      def test_chaining
        options = Nokogiri::XML::ParseOptions.new.recover.noent
        assert options.recover?
        assert options.noent?
      end

      def test_inspect
        options = Nokogiri::XML::ParseOptions.new.recover.noent
        ins = options.inspect
        assert_match(/recover/, ins)
        assert_match(/noent/, ins)
      end
    end
  end
end
