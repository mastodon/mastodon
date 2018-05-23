# frozen_string_literal: true

module Browser
  class Platform
    class WindowsMobile < Base
      def version
        "0"
      end

      def name
        "Windows Mobile"
      end

      def id
        :windows_mobile
      end

      def match?
        ua =~ /Windows CE/
      end
    end
  end
end
