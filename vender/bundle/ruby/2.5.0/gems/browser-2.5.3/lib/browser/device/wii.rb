# frozen_string_literal: true

module Browser
  class Device
    class Wii < Base
      def id
        :wii
      end

      def name
        "Nintendo Wii"
      end

      def match?
        ua =~ /Nintendo Wii/i
      end
    end
  end
end
