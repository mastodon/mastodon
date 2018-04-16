require 'tilt/template'


module Tilt
  # Raw text (no template functionality).
  class PlainTemplate < Template
    self.default_mime_type = 'text/html'

    def prepare
    end

    def evaluate(scope, locals, &block)
      @output ||= data
    end
  end
end
