# frozen_string_literal: true

module Browser
  class Platform
    class Linux < Base
      def version
        "0"
      end

      def name
        "Generic Linux"
      end

      def id
        :linux
      end

      def match?
        ua =~ /Linux/
      end
    end
  end
end
