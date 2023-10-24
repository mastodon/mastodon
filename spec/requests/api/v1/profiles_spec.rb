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
    before do
      allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_async)
    end

    context 'when deleting an avatar' do
      context 'with wrong scope' do
        before do
          delete '/api/v1/profile/avatar', headers: headers
        end

        it_behaves_like 'forbidden for wrong scope', 'read'
      end

      it 'returns http success' do
        delete '/api/v1/profile/avatar', headers: headers

        expect(response).to have_http_status(200)
      end

      it 'deletes the avatar' do
        delete '/api/v1/profile/avatar', headers: headers

        account.reload

        expect(account.avatar).to_not exist
      end

      it 'does not delete the header' do
        delete '/api/v1/profile/avatar', headers: headers

        account.reload

        expect(account.header).to exist
      end

      it 'queues up an account update distribution' do
        delete '/api/v1/profile/avatar', headers: headers

        expect(ActivityPub::UpdateDistributionWorker).to have_received(:perform_async).with(account.id)
      end
    end

    context 'when deleting a header' do
      context 'with wrong scope' do
        before do
          delete '/api/v1/profile/header', headers: headers
        end

        it_behaves_like 'forbidden for wrong scope', 'read'
      end

      it 'returns http success' do
        delete '/api/v1/profile/header', headers: headers

        expect(response).to have_http_status(200)
      end

      it 'does not delete the avatar' do
        delete '/api/v1/profile/header', headers: headers

        account.reload

        expect(account.avatar).to exist
      end

      it 'deletes the header' do
        delete '/api/v1/profile/header', headers: headers

        account.reload

        expect(account.header).to_not exist
      end

      it 'queues up an account update distribution' do
        delete '/api/v1/profile/header', headers: headers

        expect(ActivityPub::UpdateDistributionWorker).to have_received(:perform_async).with(account.id)
      end
    end
  end
end
