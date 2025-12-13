# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AccountsController do
  render_views

  before { sign_in current_user, scope: :user }

  describe 'GET #index' do
    let(:current_user) { Fabricate(:admin_user) }
    let(:params) do
      {
        origin: 'local',
        by_domain: 'domain',
        status: 'active',
        username: 'username',
        display_name: 'display name',
        email: 'local-part@domain',
        ip: '0.0.0.42',
      }
    end

    around do |example|
      default_per_page = Account.default_per_page
      Account.paginates_per 1
      example.run
      Account.paginates_per default_per_page
    end

    before do
      Fabricate(:account)

      account_filter = instance_double(AccountFilter, results: Account.all)
      allow(AccountFilter).to receive(:new).and_return(account_filter)
    end

    it 'returns success and paginates and filters with parameters' do
      get :index, params: params.merge(page: 2)

      expect(response)
        .to have_http_status(200)
      expect(accounts_table_rows.size)
        .to eq(1)
      expect(AccountFilter)
        .to have_received(:new)
        .with(hash_including(params))
    end

    def accounts_table_rows
      response.parsed_body.css('table.accounts-table tr')
    end
  end

  describe 'GET #show' do
    let(:current_user) { Fabricate(:admin_user) }

    describe 'account moderation notes' do
      let(:account) { Fabricate(:account) }

      it 'includes moderation notes' do
        note1 = Fabricate(:account_moderation_note, target_account: account, content: 'Note 1 remarks')
        note2 = Fabricate(:account_moderation_note, target_account: account, content: 'Note 2 remarks')

        get :show, params: { id: account.id }
        expect(response).to have_http_status(200)

        expect(response.body)
          .to include(note1.content)
          .and include(note2.content)
      end
    end

    context 'with a remote account' do
      let(:account) { Fabricate(:account, domain: 'example.com') }

      it 'returns http success' do
        get :show, params: { id: account.id }
        expect(response).to have_http_status(200)
      end
    end

    context 'with a local account' do
      let(:account) { Fabricate(:account, domain: nil) }

      it 'returns http success' do
        get :show, params: { id: account.id }
        expect(response).to have_http_status(200)
      end
    end

    context 'with a local deleted account' do
      let(:account) { Fabricate(:account, domain: nil, user: nil) }

      it 'returns http success' do
        get :show, params: { id: account.id }
        expect(response).to have_http_status(200)
      end
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
          expect(subject).to have_http_status 403
          expect(account.reload).to_not be_memorial
        end
      end

      context 'when target user is not admin' do
        let(:target_role) { UserRole.find_by(name: 'Moderator') }

        it 'succeeds in memorializing account' do
          expect(subject).to redirect_to admin_account_path(account.id)
          expect(account.reload).to be_memorial
        end
      end
    end

    context 'when user is not admin' do
      let(:current_role) { UserRole.find_by(name: 'Moderator') }

      context 'when target user is admin' do
        let(:target_role) { UserRole.find_by(name: 'Admin') }

        it 'fails to memorialize account' do
          expect(subject).to have_http_status 403
          expect(account.reload).to_not be_memorial
        end
      end

      context 'when target user is not admin' do
        let(:target_role) { UserRole.find_by(name: 'Moderator') }

        it 'fails to memorialize account' do
          expect(subject).to have_http_status 403
          expect(account.reload).to_not be_memorial
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
        expect(subject).to redirect_to admin_account_path(account.id)
        expect(user.reload).to_not be_disabled
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to enable account' do
        expect(subject).to have_http_status 403
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

      it 'succeeds in approving account and logs action' do
        expect(subject).to redirect_to admin_accounts_path(status: 'pending')
        expect(user.reload).to be_approved

        expect(latest_admin_action_log)
          .to be_present
          .and have_attributes(
            action: eq(:approve),
            account_id: eq(current_user.account_id),
            target_id: eq(account.user.id)
          )
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to approve account' do
        expect(subject).to have_http_status 403
        expect(user.reload).to_not be_approved
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

      it 'succeeds in rejecting account and logs action' do
        expect(subject).to redirect_to admin_accounts_path(status: 'pending')

        expect(latest_admin_action_log)
          .to be_present
          .and have_attributes(
            action: eq(:reject),
            account_id: eq(current_user.account_id),
            target_id: eq(account.user.id)
          )
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to reject account' do
        expect(subject).to have_http_status 403
        expect(user.reload).to_not be_approved
      end
    end
  end

  describe 'POST #redownload' do
    subject { post :redownload, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account, domain: 'example.com') }

    before do
      service = instance_double(ResolveAccountService, call: nil)
      allow(ResolveAccountService).to receive(:new).and_return(service)
    end

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'succeeds in redownloading' do
        expect(subject).to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to redownload' do
        expect(subject).to have_http_status 403
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
        expect(subject).to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to remove avatar' do
        expect(subject).to have_http_status 403
      end
    end
  end

  describe 'POST #unblock_email' do
    subject { post :unblock_email, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account, suspended: true) }

    before do
      _email_block = Fabricate(:canonical_email_block, reference_account: account)
    end

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'succeeds in removing email blocks and redirects to admin account path' do
        expect { subject }.to change { CanonicalEmailBlock.where(reference_account: account).count }.from(1).to(0)

        expect(response).to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to remove avatar' do
        subject
        expect(response).to have_http_status 403
      end
    end
  end

  describe 'POST #unsensitive' do
    subject { post :unsensitive, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account, sensitized_at: 1.year.ago) }

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'marks accounts not sensitized' do
        subject

        expect(account.reload).to_not be_sensitized
        expect(response).to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to change account' do
        subject

        expect(response).to have_http_status 403
      end
    end
  end

  describe 'POST #unsilence' do
    subject { post :unsilence, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account, silenced_at: 1.year.ago) }

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'marks accounts not silenced' do
        subject

        expect(account.reload).to_not be_silenced
        expect(response).to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to change account' do
        subject

        expect(response).to have_http_status 403
      end
    end
  end

  describe 'POST #unsuspend' do
    subject { post :unsuspend, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account) }

    before do
      account.suspend!
    end

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'marks accounts not suspended' do
        subject

        expect(account.reload).to_not be_suspended
        expect(response).to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to change account' do
        subject

        expect(response).to have_http_status 403
      end
    end
  end

  describe 'POST #destroy' do
    subject { post :destroy, params: { id: account.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account) }

    before do
      account.suspend!
    end

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      before do
        allow(Admin::AccountDeletionWorker).to receive(:perform_async).with(account.id)
      end

      it 'destroys the account' do
        subject

        expect(Admin::AccountDeletionWorker).to have_received(:perform_async).with(account.id)
        expect(response).to redirect_to admin_account_path(account.id)
      end
    end

    context 'when user is not admin' do
      let(:role) { UserRole.everyone }

      it 'fails to change account' do
        subject

        expect(response).to have_http_status 403
      end
    end
  end

  private

  def latest_admin_action_log
    Admin::ActionLog.last
  end
end
