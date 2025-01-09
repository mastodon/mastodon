# frozen_string_literal: true

class ScopeParser < Parslet::Parser
  rule(:term)      { match('[a-z_]').repeat(1).as(:term) }
  rule(:colon)     { str(':') }
  rule(:access)    { (str('write') | str('read')).as(:access) }
  rule(:namespace) { str('admin').as(:namespace) }
  rule(:scope)     { ((namespace >> colon).maybe >> ((access >> colon >> term) | access | term)).as(:scope) }
  root(:scope)
end
