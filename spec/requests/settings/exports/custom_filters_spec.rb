# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings / Exports / CustomFilters' do
  describe 'GET /settings/exports/custom_filters' do
    context 'with a signed in user who has custom_filters' do
      let(:user) { Fabricate(:user) }
      let(:filter) { Fabricate(:custom_filter, account: user.account, phrase: 'foo') }
      let(:other_filter) { Fabricate(:custom_filter, account: user.account, phrase: 'bar') }
      let!(:keyword) { Fabricate(:custom_filter_keyword, custom_filter: filter) }
      let!(:filter_keyword) { Fabricate(:custom_filter_keyword, keyword: 'something', custom_filter: filter, whole_word: false) }
      let!(:other_keyword) { Fabricate(:custom_filter_keyword, custom_filter: other_filter) }
      let!(:other_filter_keyword) { Fabricate(:custom_filter_keyword, keyword: 'something', custom_filter: other_filter, whole_word: false) }
      let!(:status_filter) { Fabricate(:custom_filter_status, custom_filter: filter) }
      let(:expected_response_body) do
        { 'custom_filters' => [
          {
            'title' => other_filter.phrase,
            'expires_at' => nil,
            'context' => other_filter.context,
            'action' => other_filter.action,
            'keywords_attributes' => [{
              'keyword' => other_keyword.keyword,
              'whole_word' => other_keyword.whole_word,
            }, {
              'keyword' => other_filter_keyword.keyword,
              'whole_word' => other_filter_keyword.whole_word,
            }],
            'statuses' => [],
          },
          {
            'title' => filter.phrase,
            'expires_at' => nil,
            'context' => filter.context,
            'action' => filter.action,
            'keywords_attributes' => [{
              'keyword' => keyword.keyword,
              'whole_word' => keyword.whole_word,
            }, {
              'keyword' => filter_keyword.keyword,
              'whole_word' => filter_keyword.whole_word,
            }],
            'statuses' => [ActivityPub::TagManager.instance.uri_for(status_filter.status)],
          },
        ] }
      end

      before do
        sign_in user
      end

      it 'returns a JSON with the custom filters' do
        get '/settings/exports/custom_filters.json'

        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('application/json')
        expect(response.parsed_body).to eq(expected_response_body)
      end
    end
  end
end
