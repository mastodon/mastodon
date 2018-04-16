require 'tilt/template'
require 'bluecloth'

module Tilt
  # BlueCloth Markdown implementation. See:
  # http://deveiate.org/projects/BlueCloth/
  class BlueClothTemplate < Template
    self.default_mime_type = 'text/html'

    def prepare
      @engine = BlueCloth.new(data, options)
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.to_html
    end

    def allows_script?
      false
    end
  end
end

