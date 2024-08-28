# frozen_string_literal: true

require 'rails_helper'

describe 'Manifest' do
  describe 'GET /manifest' do
    before { get '/manifest' }

    it 'returns http success' do
      expect(response)
        .to have_http_status(200)
        .and have_attributes(
          content_type: match('application/json')
        )
      expect(body_as_json)
        .to include(
          id: '/home',
          name: 'Mastodon'
        )
    end

    it_behaves_like 'cacheable response'
  end
end
