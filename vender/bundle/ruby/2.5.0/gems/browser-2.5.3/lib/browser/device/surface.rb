# frozen_string_literal: true

module Browser
  class Device
    class Surface < Base
      def id
        :surface
      end

      def name
        "Microsoft Surface"
      end

      def match?
        platform.windows_rt? && ua =~ /Touch/
      end

      private

      def platform
        @platform ||= Platform.new(ua)
      end
    end
  end
end
