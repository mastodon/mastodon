module Doorkeeper
  module OAuth
    class ErrorResponse < BaseResponse
      include OAuth::Helpers

      def self.from_request(request, attributes = {})
        new(attributes.merge(name: request.error, state: request.try(:state)))
      end

      delegate :name, :description, :state, to: :@error

      def initialize(attributes = {})
        @error = OAuth::Error.new(*attributes.values_at(:name, :state))
        @redirect_uri = attributes[:redirect_uri]
        @response_on_fragment = attributes[:response_on_fragment]
      end

      def body
        {
          error: name,
          error_description: description,
          state: state
        }.reject { |_, v| v.blank? }
      end

      def status
        :unauthorized
      end

      def redirectable?
        name != :invalid_redirect_uri && name != :invalid_client &&
          !URIChecker.native_uri?(@redirect_uri)
      end

      def redirect_uri
        if @response_on_fragment
          Authorization::URIBuilder.uri_with_fragment @redirect_uri, body
        else
          Authorization::URIBuilder.uri_with_query @redirect_uri, body
        end
      end

      def headers
        { 'Cache-Control' => 'no-store',
          'Pragma' => 'no-cache',
          'Content-Type' => 'application/json; charset=utf-8',
          'WWW-Authenticate' => authenticate_info }
      end

      protected

      delegate :realm, to: :configuration

      def configuration
        Doorkeeper.configuration
      end

      private

      def authenticate_info
        %(Bearer realm="#{realm}", error="#{name}", error_description="#{description}")
      end
    end
  end
end
