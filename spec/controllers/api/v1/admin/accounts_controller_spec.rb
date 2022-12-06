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
    let!(:remote_account)       { Fabricate(:account, domain: 'example.org') }
    let!(:other_remote_account) { Fabricate(:account, domain: 'foo.bar') }
    let!(:suspended_account)    { Fabricate(:account, suspended: true) }
    let!(:suspended_remote)     { Fabricate(:account, domain: 'foo.bar', suspended: true) }
    let!(:disabled_account)     { Fabricate(:user, disabled: true).account }
    let!(:pending_account)      { Fabricate(:user, approved: false).account }
    let!(:admin_account)        { user.account }

    let(:params) { {} }

    before do
      pending_account.user.update(approved: false)
      get :index, params: params
    end

    it_behaves_like 'forbidden for wrong scope', 'write:statuses'
    it_behaves_like 'forbidden for wrong role', 'user'

    [
      [{ active: 'true', local: 'true', staff: 'true' }, [:admin_account]],
      [{ by_domain: 'example.org', remote: 'true' }, [:remote_account]],
      [{ suspended: 'true' }, [:suspended_account]],
      [{ disabled: 'true' }, [:disabled_account]],
      [{ pending: 'true' }, [:pending_account]],
    ].each do |params, expected_results|
      context "when called with #{params.inspect}" do
        let(:params) { params }

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it "returns the correct accounts (#{expected_results.inspect})" do
          json = body_as_json

          expect(json.map { |a| a[:id].to_i }).to eq (expected_results.map { |symbol| send(symbol).id })
        end
      end
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

    it 'logs action' do
      log_item = Admin::ActionLog.last

      expect(log_item).to_not be_nil
      expect(log_item.action).to eq :approve
      expect(log_item.account_id).to eq user.account_id
      expect(log_item.target_id).to eq account.user.id
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

    it 'logs action' do
      log_item = Admin::ActionLog.last

      expect(log_item).to_not be_nil
      expect(log_item.action).to eq :reject
      expect(log_item.account_id).to eq user.account_id
      expect(log_item.target_id).to eq account.user.id
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

    it 'unsensitizes account' do
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
