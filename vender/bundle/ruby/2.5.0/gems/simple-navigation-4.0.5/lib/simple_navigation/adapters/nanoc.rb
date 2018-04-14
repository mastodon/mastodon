module SimpleNavigation
  module Adapters
    class Nanoc < Base
      class << self
        def register(root)
          SimpleNavigation.set_env(root, 'development')
          Nanoc3::Context.send(:include, SimpleNavigation::Helpers)
        end
      end

      def initialize(ctx)
        @context = ctx
      end

      # Returns the context in which the config files will be evaluated
      def context_for_eval
        context
      end

      # Returns true if the current request's url matches the specified url.
      # Used to determine if an item should be autohighlighted.
      def current_page?(url)
        path = context.item.path
        path && path.chop == url
      end

      # Returns a link with the specified name, url and options.
      # Used for rendering.
      def link_to(name, url, options = {})
        "<a href='#{url}' #{to_attributes(options)}>#{name}</a>"
      end

      # Returns a tag of the specified type, content and options.
      # Used for rendering.
      def content_tag(type, content, options = {})
        "<#{type} #{to_attributes(options)}>#{content}</#{type}>"
      end

      private

      def to_attributes(options)
        options.map { |k, v| v.nil? ? nil : "#{k}='#{v}'" }.compact.join(' ')
      end
    end
  end
end
