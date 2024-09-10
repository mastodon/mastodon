# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Languages' do
  describe 'GET /api/v1/instance/languages' do
    before do
      get '/api/v1/instance/languages'
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns the supported languages' do
      expect(response.parsed_body.pluck(:code)).to match_array LanguagesHelper::SUPPORTED_LOCALES.keys.map(&:to_s)
    end
  end
end
