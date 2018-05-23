require 'cgi'

module Aws
  module Xml
    class ErrorHandler < Seahorse::Client::Handler

      def call(context)
        @handler.call(context).on(300..599) do |response|
          response.error = error(context)
          response.data = nil
        end
      end

      private

      def error(context)
        body = context.http_response.body_contents
        if body.empty?
          code = http_status_error_code(context)
          message = ''
        else
          code, message = extract_error(body, context)
        end
        errors_module = context.client.class.errors_module
        errors_module.error_class(code).new(context, message)
      end

      def extract_error(body, context)
        [
          error_code(body, context),
          error_message(body),
        ]
      end

      def error_code(body, context)
        if matches = body.match(/<Code>(.+?)<\/Code>/)
          remove_prefix(unescape(matches[1]), context)
        else
          http_status_error_code(context)
        end
      end

      def http_status_error_code(context)
        status_code = context.http_response.status_code
        {
          302 => 'MovedTemporarily',
          304 => 'NotModified',
          400 => 'BadRequest',
          403 => 'Forbidden',
          404 => 'NotFound',
          412 => 'PreconditionFailed',
          413 => 'RequestEntityTooLarge',
        }[status_code] || "Http#{status_code}Error"
      end

      def remove_prefix(error_code, context)
        if prefix = context.config.api.metadata['errorPrefix']
          error_code.sub(/^#{prefix}/, '')
        else
          error_code
        end
      end

      def error_message(body)
        if matches = body.match(/<Message>(.+?)<\/Message>/m)
          unescape(matches[1])
        else
          ''
        end
      end

      def unescape(str)
        CGI.unescapeHTML(str)
      end

    end
  end
end
