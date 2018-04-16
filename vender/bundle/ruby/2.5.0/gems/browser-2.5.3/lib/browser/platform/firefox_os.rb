# frozen_string_literal: true

module Browser
  class Platform
    class FirefoxOS < Base
      def version
        "0"
      end

      def name
        "Firefox OS"
      end

      def id
        :firefox_os
      end

      def match?
        ua !~ /(Android|Linux|BlackBerry|Windows|Mac)/ && ua =~ /Firefox/
      end
    end
  end
end
