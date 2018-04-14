# frozen_string_literal: true

module Browser
  module Meta
    class IOS < Base
      def meta
        "ios" if browser.platform.ios?
      end
    end
  end
end
