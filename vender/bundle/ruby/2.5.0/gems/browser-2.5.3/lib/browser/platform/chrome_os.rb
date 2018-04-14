# frozen_string_literal: true

module Browser
  class Platform
    class ChromeOS < Base
      def match?
        ua =~ /CrOS/
      end

      def name
        "Chrome OS"
      end

      def id
        :chrome_os
      end

      def version
        ua[/CrOS(?: x86_64)? ([\d.]+)/, 1]
      end
    end
  end
end
