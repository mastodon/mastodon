# frozen_string_literal: true

module Browser
  class Device
    class PlayStation3 < Base
      def id
        :ps3
      end

      def name
        "PlayStation 3"
      end

      def match?
        ua =~ /PLAYSTATION 3/i
      end
    end
  end
end
