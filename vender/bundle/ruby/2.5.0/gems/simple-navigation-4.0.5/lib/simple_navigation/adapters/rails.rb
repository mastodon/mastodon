module SimpleNavigation
  module Adapters
    class Rails < Base
      attr_reader :controller, :template

      def self.register
        SimpleNavigation.set_env(::Rails.root, ::Rails.env)
        ActionController::Base.send(:include, SimpleNavigation::Helpers)
        SimpleNavigation::Helpers.instance_methods.each do |m|
          ActionController::Base.send(:helper_method, m.to_sym)
        end
      end

      def initialize(context)
        @controller = extract_controller_from context
        @template = template_from @controller
        @request = @template.request if @template
      end

      def request_uri
        return '' unless request

        if request.respond_to?(:fullpath)
          request.fullpath
        else
          request.request_uri
        end
      end

      def request_path
        request ? request.path : ''
      end

      def context_for_eval
        template   ||
        controller ||
        fail('no context set for evaluation the config file')
      end

      def current_page?(url)
        template && template.current_page?(url)
      end

      def link_to(name, url, options = {})
        template && template.link_to(link_title(name), url, options)
      end

      def content_tag(type, content, options = {})
        template && template.content_tag(type, html_safe(content), options)
      end

      protected

      def template_from(controller)
        if controller.respond_to?(:view_context)
          controller.view_context
        else
          controller.instance_variable_get(:@template)
        end
      end

      # Marks the specified input as html_safe (for Rails3).
      # Does nothing if html_safe is not defined on input.
      #
      def html_safe(input)
        input.respond_to?(:html_safe) ? input.html_safe : input
      end

      # Extracts a controller from the context.
      def extract_controller_from(context)
        if context.respond_to?(:controller)
          context.controller || context
        else
          context
        end
      end

      def link_title(name)
        if SimpleNavigation.config.consider_item_names_as_safe
          html_safe(name)
        else
          name
        end
      end
    end
  end
end
