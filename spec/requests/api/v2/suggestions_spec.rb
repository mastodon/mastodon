# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Suggestions API' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

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
  end
end
