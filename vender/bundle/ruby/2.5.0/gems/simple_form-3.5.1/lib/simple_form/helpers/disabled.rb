# frozen_string_literal: true
module SimpleForm
  module Helpers
    module Disabled
      private

      def has_disabled?
        options[:disabled] == true
      end

      def disabled_class
        :disabled if has_disabled?
      end
    end
  end
end
