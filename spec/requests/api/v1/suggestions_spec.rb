# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Suggestions' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/suggestions' do
    subject do
      get '/api/v1/suggestions', headers: headers, params: params
    end

    let(:bob) { Fabricate(:account) }
    let(:jeff) { Fabricate(:account) }
    let(:params) { {} }

    before do
      Setting.bootstrap_timeline_accounts = [bob, jeff].map(&:acct).join(',')
    end

    it_behaves_like 'forbidden for wrong scope', 'write'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns accounts' do
      subject

      expect(response.parsed_body)
        .to contain_exactly(include(id: bob.id.to_s), include(id: jeff.id.to_s))
    end

    context 'with limit param' do
      let(:params) { { limit: 1 } }

      it 'returns only the requested number of accounts' do
        subject

        expect(response.parsed_body.size).to eq 1
      end
    end

    context 'without an authorization header' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'DELETE /api/v1/suggestions/:id' do
    subject do
      delete "/api/v1/suggestions/#{jeff.id}", headers: headers
    end

    let(:bob) { Fabricate(:account) }
    let(:jeff) { Fabricate(:account) }
    let(:scopes) { 'write' }

    before do
      Setting.bootstrap_timeline_accounts = [bob, jeff].map(&:acct).join(',')
    end

    it_behaves_like 'forbidden for wrong scope', 'read'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'removes the specified suggestion' do
      subject

      expect(FollowRecommendationMute.exists?(account: user.account, target_account: jeff)).to be true
    end

    context 'without an authorization header' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
      end
    end
  end
end
