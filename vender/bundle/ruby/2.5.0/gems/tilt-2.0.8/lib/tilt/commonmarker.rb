require 'tilt/template'
require 'commonmarker'

module Tilt
  class CommonMarkerTemplate < Template
    self.default_mime_type = 'text/html'

    def prepare
      @engine = nil
      @output = nil
    end

    def evaluate(scope, locals, &block)
      CommonMarker.render_html(data, :DEFAULT)
    end

    def allows_script?
      false
    end
  end
end
