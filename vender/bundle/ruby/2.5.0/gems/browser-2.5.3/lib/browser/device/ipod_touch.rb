# frozen_string_literal: true

module Browser
  class Device
    class IpodTouch < Base
      def id
        :ipod_touch
      end

      def name
        "iPod Touch"
      end

      def match?
        ua =~ /iPod/
      end
    end
  end
end
