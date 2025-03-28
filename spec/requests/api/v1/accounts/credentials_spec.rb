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

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns the expected content' do
      subject

      expect(body_as_json).to include({
        source: hash_including({
          discoverable: false,
          indexable: false,
        }),
        locked: true,
      })
    end
  end

  describe 'POST /api/v1/accounts/update_credentials' do
    subject do
      patch '/api/v1/accounts/update_credentials', headers: headers, params: params
    end

    before do
      allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_in)
    end

    let(:params) do
      {
        avatar: fixture_file_upload('avatar.gif', 'image/gif'),
        discoverable: true,
        display_name: "Alice Isn't Dead",
        header: fixture_file_upload('attachment.jpg', 'image/jpeg'),
        indexable: true,
        locked: false,
        note: 'Hello!',
        source: {
          privacy: 'unlisted',
          sensitive: true,
        },
      }
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:accounts'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns JSON with updated attributes' do
      subject

      expect(body_as_json).to include({
        source: hash_including({
          discoverable: true,
          indexable: true,
        }),
        locked: false,
      })

      expect(ActivityPub::UpdateDistributionWorker)
        .to have_received(:perform_in).with(anything, user.account_id)
    end

    def expect_account_updates
      expect(user.account.reload)
        .to have_attributes(
          display_name: eq("Alice Isn't Dead"),
          note: 'Hello!',
          avatar: exist,
          header: exist
        )
    end

    def expect_user_updates
      expect(user.reload)
        .to have_attributes(
          setting_default_privacy: eq('unlisted'),
          setting_default_sensitive: be(true)
        )
    end
  end
end
