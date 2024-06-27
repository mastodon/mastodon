# frozen_string_literal: true

class SearchQueryParser < Parslet::Parser
  SUPPORTED_PREFIXES = %w(
    has
    is
    language
    from
    before
    after
    during
    in
  ).freeze

  # Efficiently matches disjoint strings
  class StrList < Parslet::Atoms::Base
    attr_reader :strings

    def initialize(strings)
      super()

      @strings = strings
      @pattern = Regexp.union(strings)
      @min_length = strings.map(&:length).min
    end

    def error_msgs
      @error_msgs ||= {
        premature: 'Premature end of input',
        failed: "Expected any of #{strings.inspect}, but got ",
      }
    end

    def try(source, context, _consume_all)
      match = source.match(@pattern)
      return succ(source.consume(match)) unless match.nil?

      # Input ending early:
      return context.err(self, source, error_msgs[:premature]) if source.chars_left < @min_length

      # Expected something, but got something else instead:
      error_pos = source.pos
      context.err_at(self, source, [error_msgs[:failed], source.consume(@len)], error_pos)
    end

    def to_s_inner(_prec)
      "[#{strings.map { |str| "'#{str}'" }.join(',')}]"
    end
  end

  rule(:term)      { match('[^\s]').repeat(1).as(:term) }
  rule(:colon)     { str(':') }
  rule(:space)     { match('\s').repeat(1) }
  rule(:operator)  { (str('+') | str('-')).as(:operator) }
  rule(:prefix_operator) { StrList.new(SUPPORTED_PREFIXES) }
  rule(:prefix)    { prefix_operator.as(:prefix_operator) >> colon }
  rule(:phrase)    do
    (str('"') >> match('[^"]').repeat.as(:phrase) >> str('"')) |
      (match('[“”„]') >> match('[^“”„]').repeat.as(:phrase) >> match('[“”„]')) |
      (str('«') >> match('[^«»]').repeat.as(:phrase) >> str('»')) |
      (str('「') >> match('[^「」]').repeat.as(:phrase) >> str('」')) |
      (str('《') >> match('[^《》]').repeat.as(:phrase) >> str('》'))
  end
  rule(:clause)    { (operator.maybe >> prefix.maybe.as(:prefix) >> (phrase | term)).as(:clause) }
  rule(:query)     { (clause >> space.maybe).repeat.as(:query) }
  root(:query)
end
