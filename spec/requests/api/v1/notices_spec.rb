# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'notices' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'write:accounts' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'DELETE /api/v1/notices/:id' do
    subject do
      delete '/api/v1/notices/mastodon_privacy_4_2', headers: headers
    end

    it_behaves_like 'forbidden for wrong scope', 'read'

    it 'retruns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'marks the notice as seen' do
      expect { subject }.to change { Notice.first_unseen(user.reload)&.id }.from(:mastodon_privacy_4_2) # rubocop:disable Naming/VariableNumber
    end
  end

  describe 'GET /api/v1/notices' do
    subject do
      get '/api/v1/notices', headers: headers
    end

    context 'when the user has seen all notices' do
      before do
        Notice.find(:mastodon_privacy_4_2).dismiss_for_user!(user) # rubocop:disable Naming/VariableNumber
      end

      it 'returns an empty list', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(body_as_json).to eq []
      end
    end

    context 'when the user has unseen notices' do
      it 'returns exactly one notice', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(body_as_json.size).to eq 1
      end
    end

    context 'without the authorization header' do
      let(:headers) { {} }

      it 'returns http unprocessable content' do
        subject

        expect(response).to have_http_status(422)
      end
    end
  end
end
