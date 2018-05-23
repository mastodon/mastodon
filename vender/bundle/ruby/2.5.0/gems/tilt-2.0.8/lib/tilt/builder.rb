require 'tilt/template'
require 'builder'

module Tilt
  # Builder template implementation. See:
  # http://builder.rubyforge.org/
  class BuilderTemplate < Template
    self.default_mime_type = 'text/xml'

    def prepare
      options[:indent] ||= 2
    end

    def evaluate(scope, locals, &block)
      xml = (locals[:xml] || ::Builder::XmlMarkup.new(options))

      if data.respond_to?(:to_str)
        if !locals[:xml]
          locals = locals.merge(:xml => xml)
        end
        return super(scope, locals, &block)
      end

      data.call(xml)
      xml.target!
    end

    def precompiled_postamble(locals)
      "xml.target!"
    end

    def precompiled_template(locals)
      data.to_str
    end
  end
end

