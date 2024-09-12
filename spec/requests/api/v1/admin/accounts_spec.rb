# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts' do
  let(:role)    { UserRole.find_by(name: 'Admin') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:scopes)  { 'admin:read:accounts admin:write:accounts' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/admin/accounts' do
    subject do
      get '/api/v1/admin/accounts', headers: headers, params: params
    end

    shared_examples 'a successful request' do
      it 'returns the correct accounts', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.parsed_body.pluck(:id)).to match_array(expected_results.map { |a| a.id.to_s })
      end
    end

    let!(:remote_account)    { Fabricate(:account, domain: 'example.org') }
    let!(:suspended_account) { Fabricate(:account, suspended: true) }
    let!(:disabled_account)  { Fabricate(:user, disabled: true).account }
    let!(:pending_account)   { Fabricate(:user, approved: false).account }
    let!(:admin_account)     { user.account }
    let(:params)             { {} }

    it_behaves_like 'forbidden for wrong scope', 'read read:accounts admin:write admin:write:accounts'
    it_behaves_like 'forbidden for wrong role', ''

    context 'when requesting active local staff accounts' do
      let(:expected_results) { [admin_account] }
      let(:params)           { { active: 'true', local: 'true', staff: 'true' } }

      it_behaves_like 'a successful request'
    end

    context 'when requesting remote accounts from a specified domain' do
      let(:expected_results) { [remote_account] }
      let(:params)           { { by_domain: 'example.org', remote: 'true' } }

      before do
        Fabricate(:account, domain: 'foo.bar')
      end

      it_behaves_like 'a successful request'
    end

    context 'when requesting suspended accounts' do
      let(:expected_results) { [suspended_account] }
      let(:params)           { { suspended: 'true' } }

      before do
        Fabricate(:account, domain: 'foo.bar', suspended: true)
      end

      it_behaves_like 'a successful request'
    end

    context 'when requesting disabled accounts' do
      let(:expected_results) { [disabled_account] }
      let(:params)           { { disabled: 'true' } }

      it_behaves_like 'a successful request'
    end

    context 'when requesting pending accounts' do
      let(:expected_results) { [pending_account] }
      let(:params)           { { pending: 'true' } }

      before do
        pending_account.user.update(approved: false)
      end

      it_behaves_like 'a successful request'
    end

    context 'when no parameter is given' do
      let(:expected_results) { [disabled_account, pending_account, admin_account] }

      it_behaves_like 'a successful request'
    end

    context 'with limit param' do
      let(:params) { { limit: 2 } }

      it 'returns only the requested number of accounts', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.parsed_body.size).to eq(params[:limit])
      end
    end
  end

  describe 'GET /api/v1/admin/accounts/:id' do
    subject do
      get "/api/v1/admin/accounts/#{account.id}", headers: headers
    end

    let(:account) { Fabricate(:account) }

    it_behaves_like 'forbidden for wrong scope', 'read read:accounts admin:write admin:write:accounts'
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns the requested account successfully', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to match(
        a_hash_including(id: account.id.to_s, username: account.username, email: account.user.email)
      )
    end

    context 'when the account is not found' do
      it 'returns http not found' do
        get '/api/v1/admin/accounts/-1', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v1/admin/accounts/:id/approve' do
    subject do
      post "/api/v1/admin/accounts/#{account.id}/approve", headers: headers
    end

    let(:account) { Fabricate(:account) }

    context 'when the account is pending' do
      before do
        account.user.update(approved: false)
      end

      it_behaves_like 'forbidden for wrong scope', 'write write:accounts read admin:read'
      it_behaves_like 'forbidden for wrong role', ''

      it 'approves the user successfully', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(account.reload.user_approved?).to be(true)
      end

      it 'logs action', :aggregate_failures do
        subject

        expect(latest_admin_action_log)
          .to be_present
          .and have_attributes(
            action: eq(:approve),
            account_id: eq(user.account_id),
            target_id: eq(account.user.id)
          )
      end
    end

    context 'when the account is already approved' do
      it 'returns http forbidden' do
        subject

        expect(response).to have_http_status(403)
      end
    end

    context 'when the account is not found' do
      it 'returns http not found' do
        post '/api/v1/admin/accounts/-1/approve', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v1/admin/accounts/:id/reject' do
    subject do
      post "/api/v1/admin/accounts/#{account.id}/reject", headers: headers
    end

    let(:account) { Fabricate(:account) }

    context 'when the account is pending' do
      before do
        account.user.update(approved: false)
      end

      it_behaves_like 'forbidden for wrong scope', 'write write:accounts read admin:read'
      it_behaves_like 'forbidden for wrong role', ''

      it 'removes the user successfully', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(User.where(id: account.user.id)).to_not exist
      end

      it 'logs action', :aggregate_failures do
        subject

        expect(latest_admin_action_log)
          .to be_present
          .and have_attributes(
            action: eq(:reject),
            account_id: eq(user.account_id),
            target_id: eq(account.user.id)
          )
      end
    end

    context 'when account is already approved' do
      it 'returns http forbidden' do
        subject

        expect(response).to have_http_status(403)
      end
    end

    context 'when the account is not found' do
      it 'returns http not found' do
        post '/api/v1/admin/accounts/-1/reject', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v1/admin/accounts/:id/enable' do
    subject do
      post "/api/v1/admin/accounts/#{account.id}/enable", headers: headers
    end

    let(:account) { Fabricate(:account) }

    before do
      account.user.update(disabled: true)
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:accounts read admin:read'
    it_behaves_like 'forbidden for wrong role', ''

    it 'enables the user successfully', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(account.reload.user_disabled?).to be false
    end

    context 'when the account is not found' do
      it 'returns http not found' do
        post '/api/v1/admin/accounts/-1/enable', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v1/admin/accounts/:id/unsuspend' do
    subject do
      post "/api/v1/admin/accounts/#{account.id}/unsuspend", headers: headers
    end

    let(:account) { Fabricate(:account) }

    context 'when the account is suspended' do
      before do
        account.suspend!
      end

      it_behaves_like 'forbidden for wrong scope', 'write write:accounts read admin:read'
      it_behaves_like 'forbidden for wrong role', ''

      it 'unsuspends the account successfully', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(account.reload.suspended?).to be false
      end
    end

    context 'when the account is not suspended' do
      it 'returns http forbidden' do
        subject

        expect(response).to have_http_status(403)
      end
    end

    context 'when the account is not found' do
      it 'returns http not found' do
        post '/api/v1/admin/accounts/-1/unsuspend', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v1/admin/accounts/:id/unsensitive' do
    subject do
      post "/api/v1/admin/accounts/#{account.id}/unsensitive", headers: headers
    end

    let(:account) { Fabricate(:account) }

    before do
      account.update(sensitized_at: 10.days.ago)
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:accounts read admin:read'
    it_behaves_like 'forbidden for wrong role', ''

    it 'unsensitizes the account successfully', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(account.reload.sensitized?).to be false
    end

    context 'when the account is not found' do
      it 'returns http not found' do
        post '/api/v1/admin/accounts/-1/unsensitive', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v1/admin/accounts/:id/unsilence' do
    subject do
      post "/api/v1/admin/accounts/#{account.id}/unsilence", headers: headers
    end

    let(:account) { Fabricate(:account) }

    before do
      account.update(silenced_at: 3.days.ago)
    end

    it_behaves_like 'forbidden for wrong scope', 'write write:accounts read admin:read'
    it_behaves_like 'forbidden for wrong role', ''

    it 'unsilences the account successfully', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(account.reload.silenced?).to be false
    end

    context 'when the account is not found' do
      it 'returns http not found' do
        post '/api/v1/admin/accounts/-1/unsilence', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE /api/v1/admin/accounts/:id' do
    subject do
      delete "/api/v1/admin/accounts/#{account.id}", headers: headers
    end

    let(:account) { Fabricate(:account) }

    context 'when account is suspended' do
      before do
        account.suspend!
      end

      it_behaves_like 'forbidden for wrong scope', 'write write:accounts read admin:read'
      it_behaves_like 'forbidden for wrong role', ''

      it 'deletes the account successfully', :aggregate_failures do
        allow(Admin::AccountDeletionWorker).to receive(:perform_async)
        subject

        expect(response).to have_http_status(200)
        expect(Admin::AccountDeletionWorker).to have_received(:perform_async).with(account.id).once
      end
    end

    context 'when account is not suspended' do
      it 'returns http forbidden' do
        subject

        expect(response).to have_http_status(403)
      end
    end

    context 'when the account is not found' do
      it 'returns http not found' do
        delete '/api/v1/admin/accounts/-1', headers: headers

        expect(response).to have_http_status(404)
      end
    end
  end

  private

  def latest_admin_action_log
    Admin::ActionLog.last
  end
end
