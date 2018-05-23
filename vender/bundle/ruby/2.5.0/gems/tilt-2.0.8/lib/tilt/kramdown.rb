require 'tilt/template'
require 'kramdown'

module Tilt
  # Kramdown Markdown implementation. See:
  # http://kramdown.rubyforge.org/
  class KramdownTemplate < Template
    DUMB_QUOTES = [39, 39, 34, 34]

    def prepare
      options[:smart_quotes] = DUMB_QUOTES unless options[:smartypants]
      @engine = Kramdown::Document.new(data, options)
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

