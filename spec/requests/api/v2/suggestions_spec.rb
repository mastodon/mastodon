# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Suggestions API' do
  include_context 'with API authentication', oauth_scopes: 'read'

  describe 'GET /api/v2/suggestions' do
    let(:bob) { Fabricate(:account) }
    let(:jeff) { Fabricate(:account) }
    let(:params) { {} }

    before do
      Setting.bootstrap_timeline_accounts = [bob, jeff].map(&:acct).join(',')
    end

    it 'returns the expected suggestions' do
      get '/api/v2/suggestions', headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      expect(response.parsed_body).to match_array(
        [bob, jeff].map do |account|
          hash_including({
            source: 'staff',
            sources: ['featured'],
            account: hash_including({ id: account.id.to_s }),
          })
        end
      )
    end

    context 'when `follow_recommendation` FASP is enabled', feature: :fasp do
      it 'enqueues a retrieval job and adds a header to inform the client' do
        get '/api/v2/suggestions', headers: headers

        expect(Fasp::FollowRecommendationWorker).to have_enqueued_sidekiq_job
        expect(response.headers['Mastodon-Async-Refresh']).to be_present
      end
    end
  end
end
