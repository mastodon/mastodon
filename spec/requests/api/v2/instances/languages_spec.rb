# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Languages' do
  describe 'GET /api/v2/instance/languages' do
    it 'returns http success' do
      get '/api/v2/instance/languages'

      expect(response).to have_http_status(200)
    end

    it 'returns the supported languages' do
      get '/api/v2/instance/languages'

      expect(body_as_json).to eq(LanguagesHelper::SUPPORTED_LOCALES)
    end
  end
end
