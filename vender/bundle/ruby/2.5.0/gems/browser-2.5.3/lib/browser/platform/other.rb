# frozen_string_literal: true

module Browser
  class Platform
    class Other < Base
      def version
        "0"
      end

      def name
        "Other"
      end

      def id
        :other
      end

      def match?
        true
      end
    end
  end
end
