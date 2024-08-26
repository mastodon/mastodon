# frozen_string_literal: true

require 'rails_helper'

describe 'Emojis' do
  describe 'GET /emojis/:id' do
    let(:emoji) { Fabricate(:custom_emoji, shortcode: 'coolcat') }

    it 'returns http success with correct json' do
      get "/emojis/#{emoji.id}"

      expect(response)
        .to have_http_status(200)
      expect(body_as_json)
        .to include(
          name: ':coolcat:',
          type: 'Emoji'
        )
    end
  end
end
