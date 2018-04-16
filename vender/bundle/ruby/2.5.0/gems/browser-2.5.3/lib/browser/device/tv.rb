# frozen_string_literal: true

module Browser
  class Device
    class TV < Base
      def id
        :tv
      end

      def name
        "TV"
      end

      def match?
        ua =~ /(tv|Android.*?ADT-1|Nexus Player)/i
      end
    end
  end
end
