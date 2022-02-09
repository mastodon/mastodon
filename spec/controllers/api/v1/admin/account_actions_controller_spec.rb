require 'rails_helper'

RSpec.describe Api::V1::Admin::AccountActionsController, type: :controller do
  render_views

  let(:role)   { 'moderator' }
  let(:user)   { Fabricate(:user, role: role, account: Fabricate(:account, username: 'alice')) }
  let(:scopes) { 'admin:read admin:write' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:account) { Fabricate(:user).account }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  shared_examples 'forbidden for wrong scope' do |wrong_scope|
    let(:scopes) { wrong_scope }

    it 'returns http forbidden' do
      expect(response).to have_http_status(403)
    end
  end

  shared_examples 'forbidden for wrong role' do |wrong_role|
    let(:role) { wrong_role }

    it 'returns http forbidden' do
      expect(response).to have_http_status(403)
    end
  end

  describe 'POST #create' do
    before do
      post :create, params: { account_id: account.id, type: 'disable' }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', 'user'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'performs action against account' do
      expect(account.reload.user_disabled?).to be true
    end

    it 'logs action' do
      log_item = Admin::ActionLog.last

      expect(log_item).to_not be_nil
      expect(log_item.action).to eq :disable
      expect(log_item.account_id).to eq user.account_id
      expect(log_item.target_id).to eq account.user.id
    end
  end
end
