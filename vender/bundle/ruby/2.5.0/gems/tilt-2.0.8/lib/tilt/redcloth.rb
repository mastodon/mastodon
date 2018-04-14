require 'tilt/template'
require 'redcloth'

module Tilt
  # RedCloth implementation. See:
  # http://redcloth.org/
  class RedClothTemplate < Template
    def prepare
      @engine = RedCloth.new(data)
      options.each {|k, v| @engine.send("#{k}=", v) if @engine.respond_to? "#{k}="}
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

