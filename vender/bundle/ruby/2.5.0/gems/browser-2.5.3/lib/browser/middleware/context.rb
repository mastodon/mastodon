# frozen_string_literal: true

module Browser
  class Middleware
    class Context
      attr_reader :browser, :request

      def initialize(request)
        @request = request

        @browser = Browser.new(
          request.user_agent,
          accept_language: request.env["HTTP_ACCEPT_LANGUAGE"]
        )
      end

      def redirect_to(path)
        throw :redirected, path.to_s
      end
    end
  end
end
