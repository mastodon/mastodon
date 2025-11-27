# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Instances' do
  include_context 'with API authentication'

  describe 'GET /api/v1/instance' do
    context 'when not logged in' do
      it 'returns http success and json' do
        get api_v1_instance_path

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to be_present
          .and include(title: 'Mastodon')
      end
    end

    context 'when logged in' do
      it 'returns http success and json' do
        get api_v1_instance_path, headers: headers

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to be_present
          .and include(title: 'Mastodon')
      end
    end
  end
end
