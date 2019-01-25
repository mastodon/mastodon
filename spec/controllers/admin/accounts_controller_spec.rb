require 'rails_helper'

RSpec.describe Admin::AccountsController, type: :controller do
  render_views

  before { sign_in current_user, scope: :user }

  describe 'GET #index' do
    let(:current_user) { Fabricate(:user, admin: true) }

    around do |example|
      default_per_page = Account.default_per_page
      Account.paginates_per 1
      example.run
      Account.paginates_per default_per_page
    end

    it 'filters with parameters' do
      new = AccountFilter.method(:new)

      expect(AccountFilter).to receive(:new) do |params|
        h = params.to_h

        expect(h[:local]).to eq '1'
        expect(h[:remote]).to eq '1'
        expect(h[:by_domain]).to eq 'domain'
        expect(h[:active]).to eq '1'
        expect(h[:silenced]).to eq '1'
        expect(h[:suspended]).to eq '1'
        expect(h[:username]).to eq 'username'
        expect(h[:display_name]).to eq 'display name'
        expect(h[:email]).to eq 'local-part@domain'
        expect(h[:ip]).to eq '0.0.0.42'

        new.call({})
      end

      get :index, params: {
        local: '1',
        remote: '1',
        by_domain: 'domain',
        active: '1',
        silenced: '1',
        suspended: '1',
        username: 'username',
        display_name: 'display name',
        email: 'local-part@domain',
        ip: '0.0.0.42'
      }
    end

    it 'paginates accounts' do
      Fabricate(:account)

      get :index, params: { page: 2 }

      accounts = assigns(:accounts)
      expect(accounts.count).to eq 1
      expect(accounts.klass).to be Account
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show' do
    let(:current_user) { Fabricate(:user, admin: true) }
    let(:account) { Fabricate(:account, username: 'bob') }

    it 'returns http success' do
      get :show, params: { id: account.id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #subscribe' do
    subject { post :subscribe, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, admin: admin) }
    let(:account) { Fabricate(:account) }

    context 'when user is admin' do
      let(:admin) { true }

      it { is_expected.to redirect_to admin_account_path(account.id) }
    end

    context 'when user is not admin' do
      let(:admin) { false }

      it { is_expected.to have_http_status :forbidden }
    end
  end

  describe 'POST #unsubscribe' do
    subject { post :unsubscribe, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, admin: admin) }
    let(:account) { Fabricate(:account) }

    context 'when user is admin' do
      let(:admin) { true }

      it { is_expected.to redirect_to admin_account_path(account.id) }
    end

    context 'when user is not admin' do
      let(:admin) { false }

      it { is_expected.to have_http_status :forbidden }
    end
  end

  describe 'POST #memorialize' do
    subject { post :memorialize, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, admin: current_user_admin) }
    let(:account) { Fabricate(:account, user: user) }
    let(:user) { Fabricate(:user, admin: target_user_admin) }

    context 'when user is admin' do
      let(:current_user_admin) { true }

      context 'when target user is admin' do
        let(:target_user_admin) { true }

        it 'fails to memorialize account' do
          is_expected.to have_http_status :forbidden
          expect(account.reload).not_to be_memorial
        end
      end

      context 'when target user is not admin' do
        let(:target_user_admin) { false }

        it 'succeeds in memorializing account' do
          is_expected.to redirect_to admin_account_path(account.id)
          expect(account.reload).to be_memorial
        end
      end
    end

    context 'when user is not admin' do
      let(:current_user_admin) { false }

      context 'when target user is admin' do
        let(:target_user_admin) { true }

        it 'fails to memorialize account' do
          is_expected.to have_http_status :forbidden
          expect(account.reload).not_to be_memorial
        end
      end

      context 'when target user is not admin' do
        let(:target_user_admin) { false }

        it 'fails to memorialize account' do
          is_expected.to have_http_status :forbidden
          expect(account.reload).not_to be_memorial
        end
      end
    end
  end

  describe 'POST #enable' do
    subject { post :enable, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, admin: admin) }
    let(:account) { Fabricate(:account, user: user) }
    let(:user) { Fabricate(:user, disabled: true) }

    context 'when user is admin' do
      let(:admin) { true }

      it 'succeeds in enabling account' do
        is_expected.to redirect_to admin_account_path(account.id)
        expect(user.reload).not_to be_disabled
      end
    end

    context 'when user is not admin' do
      let(:admin) { false }

      it 'fails to enable account' do
        is_expected.to have_http_status :forbidden
        expect(user.reload).to be_disabled
      end
    end
  end

  describe 'POST #redownload' do
    subject { post :redownload, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, admin: admin) }
    let(:account) { Fabricate(:account) }

    context 'when user is admin' do
      let(:admin) { true }

      it 'succeeds in redownloadin' do
        is_expected.to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:admin) { false }

      it 'fails to redownload' do
        is_expected.to have_http_status :forbidden
      end
    end
  end

  describe 'POST #remove_avatar' do
    subject { post :remove_avatar, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, admin: admin) }
    let(:account) { Fabricate(:account) }

    context 'when user is admin' do
      let(:admin) { true }

      it 'succeeds in removing avatar' do
        is_expected.to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:admin) { false }

      it 'fails to remove avatar' do
        is_expected.to have_http_status :forbidden
      end
    end
  end
end
