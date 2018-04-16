module Rack
  class Attack
    class Track
      extend Forwardable

      attr_reader :filter

      def initialize(name, options = {}, block)
        options[:type] = :track

        if options[:limit] && options[:period]
          @filter = Throttle.new(name, options, block)
        else
          @filter = Check.new(name, options, block)
        end
      end

      def_delegator :@filter, :[]
    end
  end
end
