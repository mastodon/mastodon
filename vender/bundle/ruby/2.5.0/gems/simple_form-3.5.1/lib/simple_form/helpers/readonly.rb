# frozen_string_literal: true
module SimpleForm
  module Helpers
    module Readonly
      private

      def readonly_class
        :readonly if has_readonly?
      end

      def has_readonly?
        options[:readonly] == true
      end
    end
  end
end
