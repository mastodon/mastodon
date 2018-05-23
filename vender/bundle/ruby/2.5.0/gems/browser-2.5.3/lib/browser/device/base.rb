# frozen_string_literal: true

module Browser
  class Device
    class Base
      attr_reader :ua

      def initialize(ua)
        @ua = ua
      end
    end
  end
end
