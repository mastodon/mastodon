# frozen_string_literal: true

class NokogiriHandler
  class << self
    # See "set of space-separated tokens" in the HTML5 spec.
    WHITE_SPACE = /[ \x09\x0A\x0C\x0D]+/

    def link_rel_include(token_list, token)
      token_list.to_s.downcase.split(WHITE_SPACE).include?(token.downcase)
    end
  end
end
