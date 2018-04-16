# encoding: utf-8

# This file loads and runs Simon Sapin's CSS parsing tests, which live under the
# test/css-parsing-tests directory. The original test repo can be found at:
#
# https://github.com/SimonSapin/css-parsing-tests/

require 'json'
require_relative 'support/common'

def load_css_tests(filename)
  JSON.parse(File.read(File.join(File.dirname(__FILE__), "/css-parsing-tests/#{filename}")))
end

describe 'CSS Parsing Tests' do
  describe 'component_value_list' do
    make_my_diffs_pretty!
    parallelize_me!

    tests = load_css_tests('component_value_list.json')

    tests.each_slice(2) do |test|
      css      = test[0]
      expected = test[1]

      it "should parse: #{css.gsub("\n", "\\n")}" do
        parser = Crass::Parser.new(css)
        assert_equal(expected, translate_tokens(parser.parse_component_values))
      end
    end
  end

  describe 'declaration_list' do
    make_my_diffs_pretty!
    parallelize_me!

    tests = load_css_tests('declaration_list.json')

    tests.each_slice(2) do |test|
      css      = test[0]
      expected = test[1]

      it "should parse: #{css.gsub("\n", "\\n")}" do
        parser = Crass::Parser.new(css)
        assert_equal(expected, translate_tokens(parser.parse_declarations(parser.tokens, {:strict => true})))
      end
    end
  end

  describe 'one_component_value' do
    make_my_diffs_pretty!
    parallelize_me!

    tests = load_css_tests('one_component_value.json')

    tests.each_slice(2) do |test|
      css      = test[0]
      expected = test[1]

      it "should parse: #{css.gsub("\n", "\\n")}" do
        parser = Crass::Parser.new(css)
        assert_equal(expected, translate_tokens(parser.parse_component_value)[0])
      end
    end
  end

  describe 'one_declaration' do
    make_my_diffs_pretty!
    parallelize_me!

    tests = load_css_tests('one_declaration.json')

    tests.each_slice(2) do |test|
      css      = test[0]
      expected = test[1]

      it "should parse: #{css.gsub("\n", "\\n")}" do
        parser = Crass::Parser.new(css)
        assert_equal(expected, translate_tokens(parser.parse_declaration)[0])
      end
    end
  end

  describe 'one_rule' do
    make_my_diffs_pretty!
    parallelize_me!

    tests = load_css_tests('one_rule.json')

    tests.each_slice(2) do |test|
      css      = test[0]
      expected = test[1]

      it "should parse: #{css.gsub("\n", "\\n")}" do
        parser = Crass::Parser.new(css)
        assert_equal(expected, translate_tokens(parser.parse_rule)[0])
      end
    end
  end

  describe 'rule_list' do
    make_my_diffs_pretty!
    parallelize_me!

    tests = load_css_tests('rule_list.json')

    tests.each_slice(2) do |test|
      css      = test[0]
      expected = test[1]

      it "should parse: #{css.gsub("\n", "\\n")}" do
        parser = Crass::Parser.new(css)
        rules  = parser.consume_rules

        # Remove non-standard whitespace tokens.
        rules.reject! do |token|
          node = token[:node]
          node == :whitespace
        end

        assert_equal(expected, translate_tokens(rules))
      end
    end
  end

  describe 'stylesheet' do
    make_my_diffs_pretty!
    parallelize_me!

    tests = load_css_tests('stylesheet.json')

    tests.each_slice(2) do |test|
      css      = test[0]
      expected = test[1]

      it "should parse: #{css.gsub("\n", "\\n")}" do
        parser = Crass::Parser.new(css)
        rules  = parser.consume_rules(:top_level => true)

        # Remove non-standard whitespace tokens.
        rules.reject! do |token|
          node = token[:node]
          node == :whitespace
        end

        assert_equal(expected, translate_tokens(rules))
      end
    end
  end
end
