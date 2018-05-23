# frozen_string_literal: true

module Browser
  class Device
    class WiiU < Base
      def id
        :wiiu
      end

      def name
        "Nintendo WiiU"
      end

      def match?
        ua =~ /Nintendo WiiU/i
      end
    end
  end
end
