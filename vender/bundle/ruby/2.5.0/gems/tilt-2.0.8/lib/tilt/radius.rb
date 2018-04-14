require 'tilt/template'
require 'radius'

module Tilt
  # Radius Template
  # http://github.com/jlong/radius/
  class RadiusTemplate < Template
    def self.context_class
      @context_class ||= Class.new(Radius::Context) do
        attr_accessor :tilt_scope

        def tag_missing(name, attributes)
          tilt_scope.__send__(name)
        end

        def dup
          i = super
          i.tilt_scope = tilt_scope
          i
        end
      end
    end

    def prepare
    end

    def evaluate(scope, locals, &block)
      context = self.class.context_class.new
      context.tilt_scope = scope
      context.define_tag("yield") do
        block.call
      end
      locals.each do |tag, value|
        context.define_tag(tag) do
          value
        end
      end

      options = {:tag_prefix => 'r'}.merge(@options)
      parser = Radius::Parser.new(context, options)
      parser.parse(data)
    end

    def allows_script?
      false
    end
  end
end
