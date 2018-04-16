# frozen_string_literal: true

module Browser
  class Device
    class PSVita < Base
      def id
        :psvita
      end

      def name
        "PlayStation Vita"
      end

      def match?
        ua =~ /Playstation Vita/
      end
    end
  end
end
