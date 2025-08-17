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
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body).to include({
        source: hash_including({
          discoverable: false,
          indexable: false,
        }),
        locked: true,
      })
    end

    describe 'allows the profile scope' do
      let(:scopes) { 'profile' }

      it 'returns the response successfully' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body).to include({
          locked: true,
        })
      end
    end
  end

  describe 'PATCH /api/v1/accounts/update_credentials' do
    subject do
      patch '/api/v1/accounts/update_credentials', headers: headers, params: params
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
        attribution_domains: ['example.com'],
        source: {
          privacy: 'unlisted',
          sensitive: true,
        },
      }
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:accounts'

    describe 'with empty source list' do
      let(:params) { { display_name: "I'm a cat", source: {} } }

      it 'returns http success' do
        subject
        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    describe 'with invalid data' do
      let(:params) { { note: 'a' * 2 * Account::NOTE_LENGTH_LIMIT } }

      it 'returns http unprocessable entity' do
        subject
        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    it 'returns http success with updated JSON attributes' do
      subject

      expect(response)
        .to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      expect(response.parsed_body).to include({
        source: hash_including({
          discoverable: true,
          indexable: true,
        }),
        locked: false,
      })

      expect(ActivityPub::UpdateDistributionWorker)
        .to have_enqueued_sidekiq_job(user.account_id)
    end

    def expect_account_updates
      expect(user.account.reload)
        .to have_attributes(
          display_name: eq("Alice Isn't Dead"),
          note: 'Hello!',
          avatar: exist,
          header: exist,
          attribution_domains: ['example.com']
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
