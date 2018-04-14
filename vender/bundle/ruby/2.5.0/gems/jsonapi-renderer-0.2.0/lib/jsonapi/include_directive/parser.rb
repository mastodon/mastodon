module JSONAPI
  class IncludeDirective
    # Utilities to create an IncludeDirective hash from various types of
    # inputs.
    module Parser
      module_function

      # @api private
      def parse_include_args(include_args)
        case include_args
        when Symbol
          { include_args => {} }
        when Hash
          parse_hash(include_args)
        when Array
          parse_array(include_args)
        when String
          parse_string(include_args)
        else
          {}
        end
      end

      # @api private
      def parse_string(include_string)
        include_string.split(',')
          .each_with_object({}) do |path, hash|
            deep_merge!(hash, parse_path_string(path))
        end
      end

      # @api private
      def parse_path_string(include_path)
        include_path.split('.')
          .reverse
          .reduce({}) { |a, e| { e.to_sym => a } }
      end

      # @api private
      def parse_hash(include_hash)
        include_hash.each_with_object({}) do |(key, value), hash|
          hash[key.to_sym] = parse_include_args(value)
        end
      end

      # @api private
      def parse_array(include_array)
        include_array.each_with_object({}) do |x, hash|
          deep_merge!(hash, parse_include_args(x))
        end
      end

      # @api private
      def deep_merge!(src, ext)
        ext.each do |k, v|
          if src[k].is_a?(Hash) && v.is_a?(Hash)
            deep_merge!(src[k], v)
          else
            src[k] = v
          end
        end
      end
    end
  end
end
