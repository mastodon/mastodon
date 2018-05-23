require 'tilt/template'
require 'pandoc-ruby'

module Tilt
  # Pandoc markdown implementation. See:
  # http://pandoc.org/
  class PandocTemplate < Template
    self.default_mime_type = 'text/html'

    def tilt_to_pandoc_mapping
      { :smartypants => :smart,
        :escape_html => { :f => 'markdown-raw_html' },
        :commonmark => { :f => 'commonmark' },
        :markdown_strict => { :f => 'markdown_strict' }
      }
    end

    # turn options hash into an array
    # Map tilt options to pandoc options
    # Replace hash keys with value true with symbol for key
    # Remove hash keys with value false
    # Leave other hash keys untouched
    def pandoc_options
      options.reduce([]) do |sum, (k,v)|
        case v
        when true
          sum << (tilt_to_pandoc_mapping[k] || k)
        when false
          sum
        else
          sum << { k => v }
        end
      end
    end

    def prepare
      @engine = PandocRuby.new(data, *pandoc_options)
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= @engine.to_html.strip
    end

    def allows_script?
      false
    end
  end
end
