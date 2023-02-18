require 'rails_helper'

RSpec.describe Admin::AccountsController, type: :controller do
  render_views

  before { sign_in current_user, scope: :user }

  describe 'GET #index' do
    let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

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

        expect(h[:origin]).to eq 'local'
        expect(h[:by_domain]).to eq 'domain'
        expect(h[:status]).to eq 'active'
        expect(h[:username]).to eq 'username'
        expect(h[:display_name]).to eq 'display name'
        expect(h[:email]).to eq 'local-part@domain'
        expect(h[:ip]).to eq '0.0.0.42'

        new.call({})
      end

      get :index, params: {
        origin: 'local',
        by_domain: 'domain',
        status: 'active',
        username: 'username',
        display_name: 'display name',
        email: 'local-part@domain',
        ip: '0.0.0.42',
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
    let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }
    let(:account) { Fabricate(:account) }

    it 'returns http success' do
      get :show, params: { id: account.id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #memorialize' do
    subject { post :memorialize, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, role: current_role) }
    let(:account) { user.account }
    let(:user) { Fabricate(:user, role: target_role) }

    context 'when user is admin' do
      let(:current_role) { UserRole.find_by(name: 'Admin') }

      context 'when target user is admin' do
        let(:target_role) { UserRole.find_by(name: 'Admin') }

        it 'fails to memorialize account' do
          is_expected.to have_http_status :forbidden
          expect(account.reload).not_to be_memorial
        end
      end

      context 'when target user is not admin' do
        let(:target_role) { UserRole.find_by(name: 'Moderator') }

        it 'succeeds in memorializing account' do
          is_expected.to redirect_to admin_account_path(account.id)
          expect(account.reload).to be_memorial
        end
      end
    end

    context 'when user is not admin' do
      let(:current_role) { UserRole.find_by(name: 'Moderator') }

      context 'when target user is admin' do
        let(:target_role) { UserRole.find_by(name: 'Admin') }

        it 'fails to memorialize account' do
          is_expected.to have_http_status :forbidden
          expect(account.reload).not_to be_memorial
        end
      end

      context 'when target user is not admin' do
        let(:target_role) { UserRole.find_by(name: 'Moderator') }

        it 'fails to memorialize account' do
          is_expected.to have_http_status :forbidden
          expect(account.reload).not_to be_memorial
        end
      end
    end
  end

  describe 'POST #enable' do
    subject { post :enable, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { user.account }
    let(:user) { Fabricate(:user, disabled: true) }

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'succeeds in enabling account' do
        is_expected.to redirect_to admin_account_path(account.id)
        expect(user.reload).not_to be_disabled
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to enable account' do
        is_expected.to have_http_status :forbidden
        expect(user.reload).to be_disabled
      end
    end
  end

  describe 'POST #approve' do
    subject { post :approve, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { user.account }
    let(:user) { Fabricate(:user) }

    before do
      account.user.update(approved: false)
    end

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'succeeds in approving account' do
        is_expected.to redirect_to admin_accounts_path(status: 'pending')
        expect(user.reload).to be_approved
      end

      it 'logs action' do
        is_expected.to have_http_status :found

        log_item = Admin::ActionLog.last

        expect(log_item).to_not be_nil
        expect(log_item.action).to eq :approve
        expect(log_item.account_id).to eq current_user.account_id
        expect(log_item.target_id).to eq account.user.id
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to approve account' do
        is_expected.to have_http_status :forbidden
        expect(user.reload).not_to be_approved
      end
    end
  end

  describe 'POST #reject' do
    subject { post :reject, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { user.account }
    let(:user) { Fabricate(:user) }

    before do
      account.user.update(approved: false)
    end

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'succeeds in rejecting account' do
        is_expected.to redirect_to admin_accounts_path(status: 'pending')
      end

      it 'logs action' do
        is_expected.to have_http_status :found

        log_item = Admin::ActionLog.last

        expect(log_item).to_not be_nil
        expect(log_item.action).to eq :reject
        expect(log_item.account_id).to eq current_user.account_id
        expect(log_item.target_id).to eq account.user.id
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to reject account' do
        is_expected.to have_http_status :forbidden
        expect(user.reload).not_to be_approved
      end
    end
  end

  describe 'POST #redownload' do
    subject { post :redownload, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account, domain: 'example.com') }

    before do
      allow_any_instance_of(ResolveAccountService).to receive(:call)
    end

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'succeeds in redownloading' do
        is_expected.to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to redownload' do
        is_expected.to have_http_status :forbidden
      end
    end
  end

  describe 'POST #remove_avatar' do
    subject { post :remove_avatar, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account) }

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'succeeds in removing avatar' do
        is_expected.to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to remove avatar' do
        is_expected.to have_http_status :forbidden
      end
    end
  end

  describe 'POST #unblock_email' do
    subject { post :unblock_email, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account, suspended: true) }
    let!(:email_block) { Fabricate(:canonical_email_block, reference_account: account) }

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'succeeds in removing email blocks' do
        expect { subject }.to change { CanonicalEmailBlock.where(reference_account: account).count }.from(1).to(0)
      end

      it 'redirects to admin account path' do
        subject
        expect(response).to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to remove avatar' do
        subject
        expect(response).to have_http_status :forbidden
      end
    end
  end
end
