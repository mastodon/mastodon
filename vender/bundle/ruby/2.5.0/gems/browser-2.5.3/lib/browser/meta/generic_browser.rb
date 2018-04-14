# frozen_string_literal: true

module Browser
  module Meta
    class GenericBrowser < Base
      def meta
        "#{browser.id} #{browser.id}#{browser.version}" if generic?
      end

      private

      def generic?
        !browser.safari? && !browser.chrome?
      end
    end
  end
end
