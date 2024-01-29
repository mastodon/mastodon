# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'credentials API' do
  let(:user)     { Fabricate(:user, account_attributes: { discoverable: false, locked: true, indexable: false }) }
  let(:token)    { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)   { 'read:accounts write:accounts' }
  let(:headers)  { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/accounts/verify_credentials' do
    subject do
      get '/api/v1/accounts/verify_credentials', headers: headers
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:accounts'

    it 'returns http success with expected content' do
      subject

      expect(response)
        .to have_http_status(200)
      expect(body_as_json).to include({
        source: hash_including({
          discoverable: false,
          indexable: false,
        }),
        locked: true,
      })
    end
  end

  describe 'PATCH /api/v1/accounts/update_credentials' do
    subject do
      patch '/api/v1/accounts/update_credentials', headers: headers, params: params
    end

    before { allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_async) }

    let(:params) { { discoverable: true, locked: false, indexable: true } }

    it_behaves_like 'forbidden for wrong scope', 'read read:accounts'

    it 'returns http success with updated JSON attributes' do
      subject

      expect(response)
        .to have_http_status(200)
      expect(body_as_json).to include({
        source: hash_including({
          discoverable: true,
          indexable: true,
        }),
        locked: false,
      })

      expect(ActivityPub::UpdateDistributionWorker)
        .to have_received(:perform_async).with(user.account_id)
    end
  end
end
