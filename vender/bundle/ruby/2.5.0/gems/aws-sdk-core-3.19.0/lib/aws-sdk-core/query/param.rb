module Aws
  module Query
    class Param

      # @param [String] name
      # @param [String, nil] value (nil)
      def initialize(name, value = nil)
        @name = name.to_s
        @value = value
      end

      # @return [String]
      attr_reader :name

      # @return [String, nil]
      attr_reader :value

      # @return [String]
      def to_s
        value ? "#{escape(name)}=#{escape(value)}" : "#{escape(name)}="
      end

      # @api private
      def ==(other)
        other.kind_of?(Param) &&
        other.name == name &&
        other.value == value
      end

      # @api private
      def <=> other
        name <=> other.name
      end

      private

      def escape(str)
        Seahorse::Util.uri_escape(str)
      end

    end
  end
end
