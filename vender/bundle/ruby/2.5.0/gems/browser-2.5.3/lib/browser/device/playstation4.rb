# frozen_string_literal: true

module Browser
  class Device
    class PlayStation4 < Base
      def id
        :ps4
      end

      def name
        "PlayStation 4"
      end

      def match?
        ua =~ /PLAYSTATION 4/i
      end
    end
  end
end
