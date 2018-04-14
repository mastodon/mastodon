# frozen_string_literal: true

module Browser
  module Meta
    class Id < Base
      def meta
        browser.id
      end
    end
  end
end
