# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Preferences' do
  include_context 'with API authentication'

  describe 'GET /api/v1/preferences' do
    context 'when not authorized' do
      it 'returns http unauthorized' do
        get api_v1_preferences_path

        expect(response)
          .to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with wrong scope' do
      before do
        get api_v1_preferences_path, headers: headers
      end

      it_behaves_like 'forbidden for wrong scope', 'write write:accounts'
    end

    context 'with correct scope' do
      let(:scopes) { 'read:accounts' }

      it 'returns http success' do
        get api_v1_preferences_path, headers: headers

        expect(response)
          .to have_http_status(200)

        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to be_present
      end
    end
  end
end
