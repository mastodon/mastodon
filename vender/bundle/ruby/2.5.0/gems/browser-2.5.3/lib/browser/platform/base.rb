# frozen_string_literal: true

module Browser
  class Platform
    class Base
      attr_reader :ua

      def initialize(ua)
        @ua = ua
      end

      def match?
        false
      end
    end
  end
end
