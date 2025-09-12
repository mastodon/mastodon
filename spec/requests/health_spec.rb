# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Health check endpoint' do
  describe 'GET /health' do
    it 'returns http success when server is functioning' do
      get '/health'

      expect(response)
        .to have_http_status(200)
      expect(response.body)
        .to include('OK')
      expect(response.headers)
        .to not_include('content-security-policy')
      expect(response.media_type)
        .to eq('text/plain')
    end
  end
end
