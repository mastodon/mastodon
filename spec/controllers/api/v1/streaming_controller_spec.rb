# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::StreamingController do
  around(:each) do |example|
    before = Rails.configuration.x.streaming_api_base_url
    Rails.configuration.x.streaming_api_base_url = Rails.configuration.x.web_domain
    example.run
    Rails.configuration.x.streaming_api_base_url = before
  end

  before(:each) do
    request.headers.merge! Host: Rails.configuration.x.web_domain
  end

  context 'with streaming api on same host' do
    describe 'GET #index' do
      it 'raises ActiveRecord::RecordNotFound' do
        get :index
        expect(response).to have_http_status(404)
      end
    end
  end

  context 'with streaming api on different host' do
    before(:each) do
      Rails.configuration.x.streaming_api_base_url = "wss://streaming-#{Rails.configuration.x.web_domain}"
      @streaming_host = URI.parse(Rails.configuration.x.streaming_api_base_url).host
    end

    describe 'GET #index' do
      it 'redirects to streaming host' do
        get :index, params: { access_token: 'deadbeef', stream: 'public' }
        expect(response).to have_http_status(301)
        request_uri = URI.parse(request.url)
        redirect_to_uri = URI.parse(response.location)
        %i(scheme path query fragment).each do |part|
          expect(redirect_to_uri.send(part)).to eq(request_uri.send(part)), "redirect target #{part}"
        end
        expect(redirect_to_uri.host).to eq(@streaming_host), 'redirect target host'
      end
    end
  end
end
