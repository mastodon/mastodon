# frozen_string_literal: true

module Browser
  class Platform
    class Windows < Base
      def version
        ua[/Windows NT\s*([0-9_\.]+)?/, 1] || "0"
      end

      def name
        "Windows"
      end

      def id
        :windows
      end

      def match?
        ua =~ /Windows/
      end
    end
  end
end
