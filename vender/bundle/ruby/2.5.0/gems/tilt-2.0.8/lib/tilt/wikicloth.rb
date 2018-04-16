require 'tilt/template'
require 'wikicloth'

module Tilt
  # WikiCloth implementation. See:
  # http://redcloth.org/
  class WikiClothTemplate < Template
    def prepare
      @parser = options.delete(:parser) || WikiCloth::Parser
      @engine = @parser.new options.merge(:data => data)
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
