# frozen_string_literal: true

class SearchQueryParser < Parslet::Parser
  rule(:term)      { match('[^\s]').repeat(1).as(:term) }
  rule(:colon)     { str(':') }
  rule(:space)     { match('\s').repeat(1) }
  rule(:operator)  { (str('+') | str('-')).as(:operator) }
  rule(:prefix_operator) { str('has') | str('is') | str('language') | str('from') | str('before') | str('after') | str('during') | str('in') }
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
