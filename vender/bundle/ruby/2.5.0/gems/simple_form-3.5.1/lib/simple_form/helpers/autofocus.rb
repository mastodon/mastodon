# frozen_string_literal: true
module SimpleForm
  module Helpers
    module Autofocus
      private

      def has_autofocus?
        options[:autofocus] == true
      end
    end
  end
end
