module JMESPath
  # @api private
  module Util
    class << self

      # Determines if a value is false as defined by JMESPath:
      #
      #   https://github.com/jmespath/jmespath.site/blob/master/docs/proposals/improved-filters.rst#and-expressions-1
      #
      def falsey?(value)
        !value ||
        (value.respond_to?(:empty?) && value.empty?) ||
        (value.respond_to?(:entries) && !value.entries.any?)
        # final case necessary to support Enumerable and Struct
      end
    end
  end
end
