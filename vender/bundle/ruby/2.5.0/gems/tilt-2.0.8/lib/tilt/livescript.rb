require 'tilt/template'
require 'livescript'

module Tilt
  # LiveScript template implementation. See:
  # http://livescript.net/
  #
  # LiveScript templates do not support object scopes, locals, or yield.
  class LiveScriptTemplate < Template
    self.default_mime_type = 'application/javascript'

    def prepare
    end

    def evaluate(scope, locals, &block)
      @output ||= LiveScript.compile(data, options)
    end

    def allows_script?
      false
    end
  end
end
