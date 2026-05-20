# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings / Exports / CustomFilters' do
  describe 'GET /settings/exports/custom_filters' do
    context 'with a signed in user who has custom_filters' do
      let(:user) { Fabricate(:user) }
      let(:filter) { Fabricate(:custom_filter, account: user.account, phrase: 'foo') }
      let(:keyword) { Fabricate(:custom_filter_keyword, custom_filter: filter) }
      let(:filter_keyword) { Fabricate(:custom_filter_keyword, keyword: 'something', custom_filter: filter, whole_word: false) }
      let(:status_filter) { Fabricate(:custom_filter_status, custom_filter: filter) }
      let(:create_custom_filters) { [keyword, filter_keyword, status_filter] }
      let(:expected_response_body) do
        [{
          'title' => 'foo',
          'expire_at' => nil,
          'context' => ['home', 'notifications'],
          'action' => 'warn',
          'keywords_attributes' => [{
            'keyword' => 'discourse',
            'whole_word' => true,
          }, {
            'keyword' => 'something',
            'whole_word' => false,
          }],
          'statuses' => ['Lorem ipsum dolor sit amet'],
        }]
      end

      before do
        sign_in user
      end

      it 'returns a JSON with the custom filters' do
        create_custom_filters
        get '/settings/exports/custom_filters.json'

        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('application/json')
        expect(response.parsed_body).to eq(expected_response_body)
      end
    end
  end
end
