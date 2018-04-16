module Fog
  # Fog::Formatador
  module Formatador
    PARSE_REGEX   = ::Formatador::PARSE_REGEX
    STYLES        = ::Formatador::STYLES
    INDENT_REGEX  = ::Formatador::INDENT_REGEX

    def self.formatador
      Thread.current[:formatador] ||= ::Formatador.new
    end

    def self.format(object, opts = { :include_nested => true })
      string = init_string(object)
      indent { string << object_string(object, opts) }
      string << "#{indentation}>"
    end

    def self.display_line(data)
      ::Formatador.display_line(data)
    end

    def self.display_lines(data)
      ::Formatador.display_lines(data)
    end

    def self.display_compact_table(hashes, keys = nil, &block)
      ::Formatador.display_compact_table(hashes, keys, &block)
    end

    def self.display_table(hashes, keys = nil, &block)
      ::Formatador.display_table(hashes, keys, &block)
    end

    def self.redisplay_progressbar(current, total, options = {})
      ::Formatador.redisplay_progressbar(current, total, options = {})
    end

    private

    def self.indent(&block)
      formatador.indent(&block)
    end

    def self.indentation
      formatador.indentation
    end

    def self.init_string(object)
      "#{indentation}<#{object.class.name}\n"
    end

    def self.object_string(object, opts)
      string = "#{attribute_string(object)}"
      string << "#{nested_objects_string(object)}" if opts[:include_nested]
      string
    end

    def self.attribute_string(object)
      return "" unless object.class.respond_to?(:attributes)
      if object.class.attributes.empty?
        ""
      else
        "#{indentation}#{object_attributes(object)}\n"
      end
    end

    def self.nested_objects_string(object)
      nested = ""
      return nested if object.respond_to?(:empty) and object.empty?
      return nested unless object.is_a?(Enumerable)
      nested = "#{indentation}[\n"
      indent { nested << indentation + inspect_object(object) }
      nested << "#{indentation}\n#{indentation}]\n"
    end

    def self.object_attributes(object)
      attrs = object.class.attributes.map do |attr|
        "#{attr}=#{object.send(attr).inspect}"
      end
      attrs.join(",\n#{indentation}")
    end

    def self.inspect_object(object)
      return "" unless object.is_a?(Enumerable)
      object.map { |o| indentation + o.inspect }.join(", \n#{indentation}")
    end
  end
end
