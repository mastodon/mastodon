require 'rails_helper'

describe Api::V1::Accounts::CredentialsController do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'write') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    describe 'with valid data' do
      before do
        patch :update, params: {
          display_name: "Alice Isn't Dead",
          note: "Hi!\n\nToot toot!",
          avatar: fixture_file_upload('files/avatar.gif', 'image/gif'),
          header: fixture_file_upload('files/attachment.jpg', 'image/jpeg'),
        }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'updates account info' do
        user.account.reload

        expect(user.account.display_name).to eq("Alice Isn't Dead")
        expect(user.account.note).to eq("Hi!\n\nToot toot!")
        expect(user.account.avatar).to exist
        expect(user.account.header).to exist
      end
    end

    describe 'with invalid data' do
      before do
        patch :update, params: { note: 'This is too long. ' * 10 }
      end

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
