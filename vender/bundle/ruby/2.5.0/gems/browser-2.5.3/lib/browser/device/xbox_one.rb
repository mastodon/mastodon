# frozen_string_literal: true

module Browser
  class Device
    class XboxOne < Base
      def id
        :xbox_one
      end

      def name
        "Xbox One"
      end

      def match?
        ua =~ /Xbox One/i
      end
    end
  end
end
