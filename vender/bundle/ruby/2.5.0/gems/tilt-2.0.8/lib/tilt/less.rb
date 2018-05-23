require 'tilt/template'
require 'less'

module Tilt
  # Lessscss template implementation. See:
  # http://lesscss.org/
  #
  # Less templates do not support object scopes, locals, or yield.
  class LessTemplate < Template
    self.default_mime_type = 'text/css'

    def prepare
      if ::Less.const_defined? :Engine
        @engine = ::Less::Engine.new(data)
      else
        parser  = ::Less::Parser.new(options.merge :filename => eval_file, :line => line)
        @engine = parser.parse(data)
      end
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.to_css(options)
    end

    def allows_script?
      false
    end
  end
end

