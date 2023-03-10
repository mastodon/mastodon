# frozen_string_literal: true

class SearchQueryParser < Parslet::Parser
  rule(:term)      { match('[^\s"]').repeat(1).as(:term) }
  rule(:quote)     { str('"') }
  rule(:colon)     { str(':') }
  rule(:hash)      { str('#') }
  rule(:space)     { match('\s').repeat(1) }
  rule(:operator)  { (str('+') | str('-')).as(:operator) }
  # See SearchQueryTransformer::PrefixClause::initialize for list of legal prefix operators.
  rule(:prefix)    { ((str('domain') | str('is') | str('has') | str('lang') | str('sensitive') | str('before') | str('after') | str('from') | str('scope') | str('sort')).as(:prefix) >> colon) }
  # See CustomEmoji::SHORTCODE_RE_FRAGMENT and SCAN_RE for emoji grammar.
  rule(:shortcode) { (colon >> match('[a-zA-Z0-9_]').repeat(2).as(:shortcode) >> colon) }
  rule(:hashtag)   { (hash >> match('[^\s#]').repeat(1).as(:hashtag)) }
  rule(:phrase)    { (quote >> match('[^"]').repeat.as(:phrase) >> quote) }
  rule(:clause)    { (operator.maybe >> prefix.maybe >> (phrase | shortcode | hashtag | term)).as(:clause) }
  rule(:query)     { (clause >> space.maybe).repeat.as(:query) }
  root(:query)
end
