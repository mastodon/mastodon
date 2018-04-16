# frozen_string_literal: true
module SimpleForm
  module Wrappers
    # A wrapper is an object that holds several components and render them.
    # A component may be any object that responds to `render`.
    # This API allows inputs/components to be easily wrapped, removing the
    # need to modify the code only to wrap input in an extra tag.
    #
    # `Many` represents a wrapper around several components at the same time.
    # It may optionally receive a namespace, allowing it to be configured
    # on demand on input generation.
    class Many
      attr_reader :namespace, :defaults, :components

      def initialize(namespace, components, defaults = {})
        @namespace  = namespace
        @components = components
        @defaults   = defaults
        @defaults[:tag]   = :div unless @defaults.key?(:tag)
        @defaults[:class] = Array(@defaults[:class])
      end

      def render(input)
        content = "".html_safe
        options = input.options

        components.each do |component|
          next if options[component.namespace] == false
          rendered = component.render(input)
          content.safe_concat rendered.to_s if rendered
        end

        wrap(input, options, content)
      end

      def find(name)
        return self if namespace == name

        @components.each do |c|
          if c.is_a?(Symbol)
            return nil if c == namespace
          elsif value = c.find(name)
            return value
          end
        end

        nil
      end

      private

      def wrap(input, options, content)
        return content if options[namespace] == false
        return if defaults[:unless_blank] && content.empty?

        tag = (namespace && options[:"#{namespace}_tag"]) || @defaults[:tag]
        return content unless tag

        klass = html_classes(input, options)
        opts  = html_options(options)
        opts[:class] = (klass << opts[:class]).join(' ').strip unless klass.empty?
        input.template.content_tag(tag, content, opts)
      end

      def html_options(options)
        (@defaults[:html] || {}).merge(options[:"#{namespace}_html"] || {})
      end

      def html_classes(input, options)
        @defaults[:class].dup
      end
    end
  end
end
