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

    let(:bob)    { Fabricate(:account) }
    let(:jeff)   { Fabricate(:account) }
    let(:params) { {} }

    before do
      PotentialFriendshipTracker.record(user.account_id, bob.id, :reblog)
      PotentialFriendshipTracker.record(user.account_id, jeff.id, :favourite)
    end

    it_behaves_like 'forbidden for wrong scope', 'write'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns accounts' do
      subject

      body = body_as_json

      expect(body.size).to eq 2
      expect(body.pluck(:id)).to match_array([bob, jeff].map { |i| i.id.to_s })
    end

    context 'with limit param' do
      let(:params) { { limit: 1 } }

      it 'returns only the requested number of accounts' do
        subject

        expect(body_as_json.size).to eq 1
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

    let(:suggestions_source) { instance_double(AccountSuggestions::PastInteractionsSource, remove: nil) }
    let(:bob)                { Fabricate(:account) }
    let(:jeff)               { Fabricate(:account) }

    before do
      PotentialFriendshipTracker.record(user.account_id, bob.id, :reblog)
      PotentialFriendshipTracker.record(user.account_id, jeff.id, :favourite)
      allow(AccountSuggestions::PastInteractionsSource).to receive(:new).and_return(suggestions_source)
    end

    it_behaves_like 'forbidden for wrong scope', 'write'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'removes the specified suggestion' do
      subject

      expect(suggestions_source).to have_received(:remove).with(user.account, jeff.id.to_s).once
      expect(suggestions_source).to_not have_received(:remove).with(user.account, bob.id.to_s)
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
