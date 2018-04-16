require 'tilt/template'
require 'maruku'

module Tilt
  # Maruku markdown implementation. See:
  # http://maruku.rubyforge.org/
  class MarukuTemplate < Template
    def prepare
      @engine = Maruku.new(data, options)
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

