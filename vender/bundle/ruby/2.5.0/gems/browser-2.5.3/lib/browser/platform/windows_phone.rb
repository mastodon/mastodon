# frozen_string_literal: true

module Browser
  class Platform
    class WindowsPhone < Base
      def version
        ua[/Windows Phone ([\d.]+)/, 1]
      end

      def name
        "Windows Phone"
      end

      def id
        :windows_phone
      end

      def match?
        ua =~ /Windows Phone/
      end
    end
  end
end
