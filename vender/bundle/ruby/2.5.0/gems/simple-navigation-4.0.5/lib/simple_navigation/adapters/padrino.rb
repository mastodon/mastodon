module SimpleNavigation
  module Adapters
    class Padrino < Sinatra
      def self.register(app)
        SimpleNavigation.set_env(::Padrino.root, ::Padrino.env)
        ::Padrino::Application.send(:helpers, SimpleNavigation::Helpers)
      end

      def link_to(name, url, options = {})
        context.link_to(name, url, options)
      end

      def content_tag(type, content, options = {})
        context.content_tag(type, content.html_safe, options)
      end
    end
  end
end
