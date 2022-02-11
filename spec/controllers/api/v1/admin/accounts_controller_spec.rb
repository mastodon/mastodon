require 'rails_helper'

RSpec.describe Api::V1::Admin::AccountsController, type: :controller do
  render_views

  let(:role)   { 'moderator' }
  let(:user)   { Fabricate(:user, role: role) }
  let(:scopes) { 'admin:read admin:write' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:account) { Fabricate(:account) }

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

  describe 'GET #index' do
    before do
      get :index
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', 'user'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show' do
    before do
      get :show, params: { id: account.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', 'user'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #approve' do
    before do
      account.user.update(approved: false)
      post :approve, params: { id: account.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', 'user'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'approves user' do
      expect(account.reload.user_approved?).to be true
    end
  end

  describe 'POST #reject' do
    before do
      account.user.update(approved: false)
      post :reject, params: { id: account.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', 'user'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'removes user' do
      expect(User.where(id: account.user.id).count).to eq 0
    end
  end

  describe 'POST #enable' do
    before do
      account.user.update(disabled: true)
      post :enable, params: { id: account.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', 'user'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'enables user' do
      expect(account.reload.user_disabled?).to be false
    end
  end

  describe 'POST #unsuspend' do
    before do
      account.suspend!
      post :unsuspend, params: { id: account.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', 'user'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'unsuspends account' do
      expect(account.reload.suspended?).to be false
    end
  end

  describe 'POST #unsensitive' do
    before do
      account.touch(:sensitized_at)
      post :unsensitive, params: { id: account.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', 'user'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'unsensitives account' do
      expect(account.reload.sensitized?).to be false
    end
  end

  describe 'POST #unsilence' do
    before do
      account.touch(:silenced_at)
      post :unsilence, params: { id: account.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', 'user'

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'unsilences account' do
      expect(account.reload.silenced?).to be false
    end
  end
end
