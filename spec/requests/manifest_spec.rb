# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manifest' do
  describe 'GET /manifest' do
    before { get '/manifest' }

    it 'returns http success' do
      expect(response)
        .to have_http_status(200)
        .and have_cacheable_headers
        .and have_attributes(
          content_type: match('application/json')
        )
      expect(response.parsed_body)
        .to include(
          id: '/home',
          name: 'Mastodon',
          related_applications: include(
            include(platform: 'play', url: /play.google/),
            include(platform: 'itunes', url: /apps.apple/),
            include(platform: 'f-droid', url: /f-droid.org/)
          )
        )
    end
  end
end
