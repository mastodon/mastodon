# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Emojis' do
  describe 'GET /emojis/:id' do
    let(:emoji) { Fabricate(:custom_emoji, shortcode: 'coolcat') }

    it 'returns http success with correct json' do
      get "/emojis/#{emoji.id}"

      expect(response)
        .to have_http_status(200)
      expect(response.parsed_body)
        .to include(
          name: ':coolcat:',
          type: 'Emoji'
        )
    end
  end
end
