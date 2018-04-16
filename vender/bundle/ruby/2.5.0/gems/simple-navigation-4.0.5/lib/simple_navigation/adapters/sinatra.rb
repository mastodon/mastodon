require 'cgi'

module SimpleNavigation
  module Adapters
    class Sinatra < Base
      def self.register(app)
        SimpleNavigation.set_env(app.root, app.environment)
      end

      def initialize(context)
        @context = context
        @request = context.request
      end

      def context_for_eval
        context || fail('no context set for evaluation the config file')
      end

      def request_uri
        request.fullpath
      end

      def request_path
        request.path
      end

      def current_page?(url)
        url_string = CGI.unescape(url)
        uri = if url_string.index('?')
                request_uri
              else
                request_uri.split('?').first
              end

        if url_string =~ %r(^\w+://)
          uri = "#{request.scheme}://#{request.host_with_port}#{uri}"
        end

        url_string == CGI.unescape(uri)
      end

      def link_to(name, url, options = {})
        "<a href='#{url}'#{to_attributes(options)}>#{name}</a>"
      end

      def content_tag(type, content, options = {})
        "<#{type}#{to_attributes(options)}>#{content}</#{type}>"
      end

      protected

      def to_attributes(options)
        options.map { |k, v| v.nil? ? '' : " #{k}='#{v}'" }.join
      end
    end
  end
end
