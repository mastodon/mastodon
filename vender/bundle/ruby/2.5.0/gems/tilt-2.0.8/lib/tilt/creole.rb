require 'tilt/template'
require 'creole'

module Tilt
  # Creole implementation. See:
  # http://www.wikicreole.org/
  class CreoleTemplate < Template
    def prepare
      opts = {}
      [:allowed_schemes, :extensions, :no_escape].each do |k|
        opts[k] = options[k] if options[k]
      end
      @engine = Creole::Parser.new(data, opts)
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
