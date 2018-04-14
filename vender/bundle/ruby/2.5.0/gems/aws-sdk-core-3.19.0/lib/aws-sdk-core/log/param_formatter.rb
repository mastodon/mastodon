require 'pathname'

module Aws
  module Log
    # @api private
    class ParamFormatter

      # String longer than the max string size are truncated
      MAX_STRING_SIZE = 1000

      def initialize(options = {})
        @max_string_size = options[:max_string_size] || MAX_STRING_SIZE
      end

      def summarize(value)
        Hash === value ? summarize_hash(value) : summarize_value(value)
      end

      private

      def summarize_hash(hash)
        hash.keys.first.is_a?(String) ?
          summarize_string_hash(hash) :
          summarize_symbol_hash(hash)
      end

      def summarize_symbol_hash(hash)
        hash.map do |key,v|
          "#{key}:#{summarize_value(v)}"
        end.join(",")
      end

      def summarize_string_hash(hash)
        hash.map do |key,v|
          "#{key.inspect}=>#{summarize_value(v)}"
        end.join(",")
      end

      def summarize_string(str)
        if str.size > @max_string_size
          "#<String #{str[0...@max_string_size].inspect} ... (#{str.size} bytes)>"
        else
          str.inspect
        end
      end

      def summarize_value(value)
        case value
        when String   then summarize_string(value)
        when Hash     then '{' + summarize_hash(value) + '}'
        when Array    then summarize_array(value)
        when File     then summarize_file(value.path)
        when Pathname then summarize_file(value)
        else value.inspect
        end
      end

      def summarize_file(path)
        "#<File:#{path} (#{File.size(path)} bytes)>"
      end

      def summarize_array(array)
        "[" + array.map{|v| summarize_value(v) }.join(",") + "]"
      end

    end
  end
end
