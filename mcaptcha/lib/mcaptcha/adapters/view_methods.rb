# frozen_string_literal: true

module Mcaptcha
  module Adapters
    module ViewMethods
      def mcaptcha_tags(options = {})
        ::Mcaptcha::Helpers.mcaptcha(options)
      end
    end
  end
end
