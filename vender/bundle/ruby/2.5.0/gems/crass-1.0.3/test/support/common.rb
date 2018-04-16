# encoding: utf-8
gem 'minitest'
require 'minitest/autorun'

require_relative '../../lib/crass'

CP = Crass::Parser
CT = Crass::Tokenizer

# Hack shared test support into MiniTest.
MiniTest::Spec.class_eval do
  def self.shared_tests
    @shared_tests ||= {}
  end
end

module MiniTest::Spec::SharedTests
  def behaves_like(desc)
    self.instance_eval(&MiniTest::Spec.shared_tests[desc])
  end

  def shared_tests_for(desc, &block)
    MiniTest::Spec.shared_tests[desc] = block
  end
end

Object.class_eval { include MiniTest::Spec::SharedTests }

# Custom assertions and helpers.
def assert_tokens(input, actual, offset = 0, options = {})
  actual = [actual] unless actual.is_a?(Array)
  tokens = tokenize(input, offset, options)

  assert_equal tokens, actual
end

def reposition_tokens(tokens, offset)
  tokens.each {|token| token[:pos] += offset }
  tokens
end

def tokenize(input, offset = 0, options = {})
  tokens = CT.tokenize(input, options)
  reposition_tokens(tokens, offset) unless offset == 0
  tokens
end

# Translates Crass tokens into a form that can be compared to the expected
# values of Simon Sapin's CSS parsing tests.
#
# https://github.com/SimonSapin/css-parsing-tests/#result-representation
def translate_tokens(tokens)
  return [] if tokens.nil?

  translated = []
  tokens     = [tokens] unless tokens.is_a?(Array)

  tokens.each do |token|
    value = token[:value]

    result = case token[:node]

    # Rules and declarations.
    when :at_rule
      ['at-rule', token[:name], translate_tokens(token[:prelude]), token[:block] ? translate_tokens(token[:block]) : nil]

    when :qualified_rule
      ['qualified rule', translate_tokens(token[:prelude]), token[:block] ? translate_tokens(token[:block]) : nil]

    when :declaration
      ['declaration', token[:name], translate_tokens(value), token[:important]]

    # Component values.
    when :at_keyword
      ['at-keyword', value]

    when :bad_string
      ['error', 'bad-string']

    when :bad_url
      ['error', 'bad-url']

    when :cdc
      '-->'

    when :cdo
      '<!--'

    when :colon
      ':'

    when :column
      '||'

    when :comma
      ','

    when :dash_match
      '|='

    when :delim
      value

    when :dimension
      ['dimension', token[:repr], value, token[:type].to_s, token[:unit]]

    when :error
      ['error', value]

    when :function
      if token[:name]
        ['function', token[:name]].concat(translate_tokens(value))
      else
        ['function', value]
      end

    when :hash
      ['hash', value, token[:type].to_s]

    when :ident
      ['ident', value]

    when :include_match
      '~='

    when :number
      ['number', token[:repr], value, token[:type].to_s]

    when :percentage
      ['percentage', token[:repr], value, token[:type].to_s]

    when :prefix_match
      '^='

    when :semicolon
      ';'

    when :simple_block
      [token[:start] + token[:end]].concat(translate_tokens(value))

    when :string
      ['string', value]

    when :substring_match
      '*='

    when :suffix_match
      '$='

    when :unicode_range
      ['unicode-range', token[:start], token[:end]]

    when :url
      ['url', value]

    when :whitespace
      ' '

    when :'}', :']', :')'
      ['error', token[:node].to_s]

    else
      nil
    end

    translated << result unless result.nil?
  end

  translated
end
