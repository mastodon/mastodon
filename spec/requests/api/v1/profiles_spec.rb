# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Deleting profile images' do
  let(:account) do
    Fabricate(
      :account,
      avatar: fixture_file_upload('avatar.gif', 'image/gif'),
      header: fixture_file_upload('attachment.jpg', 'image/jpeg')
    )
  end
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: account.user.id, scopes: scopes) }
  let(:scopes)  { 'write:accounts' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'DELETE /api/v1/profile' do
    context 'when deleting an avatar' do
      context 'with wrong scope' do
        before do
          delete '/api/v1/profile/avatar', headers: headers
        end

        it_behaves_like 'forbidden for wrong scope', 'read'
      end

      it 'returns http success and deletes the avatar, preserves the header, queues up distribution' do
        delete '/api/v1/profile/avatar', headers: headers

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        account.reload
        expect(account.avatar).to_not exist
        expect(account.header).to exist
        expect(ActivityPub::UpdateDistributionWorker)
          .to have_enqueued_sidekiq_job(account.id)
      end
    end

    context 'when deleting a header' do
      context 'with wrong scope' do
        before do
          delete '/api/v1/profile/header', headers: headers
        end

        it_behaves_like 'forbidden for wrong scope', 'read'
      end

      it 'returns http success, preserves the avatar, deletes the header, queues up distribution' do
        delete '/api/v1/profile/header', headers: headers

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        account.reload
        expect(account.avatar).to exist
        expect(account.header).to_not exist
        expect(ActivityPub::UpdateDistributionWorker)
          .to have_enqueued_sidekiq_job(account.id)
      end
    end
  end
end
