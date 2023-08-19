# frozen_string_literal: true

# Monkey patching until https://github.com/sparklemotion/http-cookie/pull/44 is merged
class HTTP::Cookie
  class << self
    alias original_parse parse

    def parse(set_cookie, origin, options = nil)
      origin = Addressable::URI.parse(origin).normalize
      original_parse(set_cookie, origin, options)
    end
  end
end
