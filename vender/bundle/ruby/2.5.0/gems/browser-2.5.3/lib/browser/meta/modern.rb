# frozen_string_literal: true

module Browser
  module Meta
    class Modern < Base
      def meta
        "modern" if browser.modern?
      end
    end
  end
end
