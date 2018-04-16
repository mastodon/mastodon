# frozen_string_literal: true

module Browser
  class Device
    class PSP < Base
      def id
        :psp
      end

      def name
        "PlayStation Portable"
      end

      def match?
        ua =~ /PlayStation Portable/
      end
    end
  end
end
