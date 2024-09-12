# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Streaming' do
  around do |example|
    before = Rails.configuration.x.streaming_api_base_url
    Rails.configuration.x.streaming_api_base_url = "wss://#{Rails.configuration.x.web_domain}"
    example.run
    Rails.configuration.x.streaming_api_base_url = before
  end

  context 'with streaming api on same host' do
    describe 'GET /api/v1/streaming' do
      it 'raises ActiveRecord::RecordNotFound' do
        integration_session.https!(false)
        get '/api/v1/streaming'

        expect(response).to have_http_status(404)
      end
    end
  end

  context 'with streaming api on different host' do
    before do
      Rails.configuration.x.streaming_api_base_url = "wss://streaming-#{Rails.configuration.x.web_domain}"
    end

    describe 'GET /api/v1/streaming' do
      it 'redirects to streaming host' do
        get '/api/v1/streaming', headers: headers, params: { access_token: 'deadbeef', stream: 'public' }

        expect(response)
          .to have_http_status(301)

        expect(redirect_to_uri)
          .to have_attributes(
            fragment: request_uri.fragment,
            host: eq(streaming_host),
            path: request_uri.path,
            query: request_uri.query,
            scheme: request_uri.scheme
          )
      end

      private

      def request_uri
        URI.parse(request.url)
      end

      def redirect_to_uri
        URI.parse(response.location)
      end

      def streaming_host
        URI.parse(Rails.configuration.x.streaming_api_base_url).host
      end
    end
  end
end
