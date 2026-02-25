# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom Emojis' do
  include_context 'with API authentication'

  describe 'GET /api/v1/custom_emojis' do
    before do
      Fabricate(:custom_emoji, domain: nil, disabled: false, visible_in_picker: true, shortcode: 'coolcat')
    end

    context 'when logged out' do
      it 'returns http success and json' do
        get api_v1_custom_emojis_path

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to be_present
          .and have_attributes(
            first: include(shortcode: 'coolcat')
          )
      end
    end

    context 'when logged in' do
      it 'returns http success and json' do
        get api_v1_custom_emojis_path, headers: headers

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to be_present
          .and have_attributes(
            first: include(shortcode: 'coolcat')
          )
      end
    end
  end
end
