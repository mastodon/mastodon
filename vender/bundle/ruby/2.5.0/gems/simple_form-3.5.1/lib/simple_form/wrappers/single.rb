# frozen_string_literal: true
module SimpleForm
  module Wrappers
    # `Single` is an optimization for a wrapper that has only one component.
    class Single < Many
      def initialize(name, wrapper_options = {}, options = {})
        @component = Leaf.new(name, options)

        super(name, [@component], wrapper_options)
      end

      def render(input)
        options = input.options
        if options[namespace] != false
          content = @component.render(input)
          wrap(input, options, content) if content
        end
      end

      private

      def html_options(options)
        %i[label input].include?(namespace) ? {} : super
      end
    end
  end
end
