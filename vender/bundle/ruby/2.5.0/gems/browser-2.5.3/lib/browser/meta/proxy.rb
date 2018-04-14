# frozen_string_literal: true

module Browser
  module Meta
    class Proxy < Base
      def meta
        "proxy" if browser.proxy?
      end
    end
  end
end
