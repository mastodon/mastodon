# frozen_string_literal: true
module SimpleForm
  module Inputs
    class BlockInput < Base
      def initialize(*args, &block)
        super
        @block = block
      end

      def input(wrapper_options = nil)
        template.capture(&@block)
      end
    end
  end
end
