module Rack
  class Attack
    class Safelist < Check
      def initialize(name, block)
        super
        @type = :safelist
      end

    end
  end
end
