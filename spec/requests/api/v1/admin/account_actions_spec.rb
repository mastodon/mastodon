# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Account actions' do
  let(:role)    { UserRole.find_by(name: 'Admin') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:scopes)  { 'admin:write admin:write:accounts' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  shared_examples 'a successful notification delivery' do
    it 'notifies the user about the action taken', :inline_jobs do
      emails = capture_emails { subject }

      expect(emails.size)
        .to eq(1)

      expect(emails.first)
        .to have_attributes(
          to: contain_exactly(target_account.user.email)
        )
    end
  end

  shared_examples 'a successful logged action' do |action_type, target_type|
    it 'logs action' do
      subject

      expect(latest_admin_action_log)
        .to be_present
        .and have_attributes(
          action: eq(action_type),
          account_id: eq(user.account_id),
          target_id: eq(target_type == :user ? target_account.user.id : target_account.id)
        )
    end

    private

    def latest_admin_action_log
      Admin::ActionLog.last
    end
  end

  describe 'POST /api/v1/admin/accounts/:id/action' do
    subject do
      post "/api/v1/admin/accounts/#{target_account.id}/action", headers: headers, params: params
    end

    let(:target_account) { Fabricate(:account) }

    context 'with type of disable' do
      let(:params) { { type: 'disable' } }

      it_behaves_like 'forbidden for wrong scope', 'admin:read admin:read:accounts'
      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'a successful notification delivery'
      it_behaves_like 'a successful logged action', :disable, :user

      it 'disables the target account' do
        expect { subject }.to change { target_account.reload.user_disabled? }.from(false).to(true)
        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with type of sensitive' do
      let(:params) { { type: 'sensitive' } }

      it_behaves_like 'forbidden for wrong scope', 'admin:read admin:read:accounts'
      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'a successful notification delivery'
      it_behaves_like 'a successful logged action', :sensitive, :account

      it 'marks the target account as sensitive' do
        expect { subject }.to change { target_account.reload.sensitized? }.from(false).to(true)
        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with type of silence' do
      let(:params) { { type: 'silence' } }

      it_behaves_like 'forbidden for wrong scope', 'admin:read admin:read:accounts'
      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'a successful notification delivery'
      it_behaves_like 'a successful logged action', :silence, :account

      it 'marks the target account as silenced' do
        expect { subject }.to change { target_account.reload.silenced? }.from(false).to(true)
        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with type of suspend' do
      let(:params) { { type: 'suspend' } }

      it_behaves_like 'forbidden for wrong scope', 'admin:read admin:read:accounts'
      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'a successful notification delivery'
      it_behaves_like 'a successful logged action', :suspend, :account

      it 'marks the target account as suspended' do
        expect { subject }.to change { target_account.reload.suspended? }.from(false).to(true)
        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with type of none' do
      let(:params) { { type: 'none' } }

      it_behaves_like 'a successful notification delivery'

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with no type' do
      let(:params) { {} }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with invalid type' do
      let(:params) { { type: 'invalid' } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
