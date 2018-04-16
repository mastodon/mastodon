module Aws
  module Json
    class ErrorHandler < Xml::ErrorHandler

      # @param [Seahorse::Client::RequestContext] context
      # @return [Seahorse::Client::Response]
      def call(context)
        @handler.call(context).on(300..599) do |response|
          response.error = error(context)
          response.data = nil
        end
      end

      private

      def extract_error(body, context)
        json = Json.load(body)
        code = error_code(json, context)
        message = error_message(code, json)
        [code, message]
      rescue Json::ParseError
        [http_status_error_code(context), '']
      end

      def error_code(json, context)
        code = json['__type']
        code ||= json['code']
        code ||= context.http_response.headers['x-amzn-errortype']
        if code
          code.split('#').last
        else
          http_status_error_code(context)
        end
      end

      def error_message(code, json)
        if code == 'RequestEntityTooLarge'
          'Request body must be less than 1 MB'
        else
          json['message'] || json['Message'] || ''
        end
      end

    end
  end
end
