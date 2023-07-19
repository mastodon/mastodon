# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Account actions' do
  let(:role)    { UserRole.find_by(name: 'Admin') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:scopes)  { 'admin:write admin:write:accounts' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:mailer)  { instance_double(ActionMailer::MessageDelivery, deliver_later!: nil) }

  before do
    allow(UserMailer).to receive(:warning).with(target_account.user, anything).and_return(mailer)
  end

  shared_examples 'a successful notification delivery' do
    it 'notifies the user about the action taken' do
      subject

      expect(UserMailer).to have_received(:warning).with(target_account.user, anything).once
      expect(mailer).to have_received(:deliver_later!).once
    end
  end

  shared_examples 'a successful logged action' do |action_type, target_type|
    it 'logs action' do
      subject

      log_item = Admin::ActionLog.last

      expect(log_item).to be_present
      expect(log_item.action).to eq(action_type)
      expect(log_item.account_id).to eq(user.account_id)
      expect(log_item.target_id).to eq(target_type == :user ? target_account.user.id : target_account.id)
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

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'disables the target account' do
        expect { subject }.to change { target_account.reload.user_disabled? }.from(false).to(true)
      end
    end

    context 'with type of sensitive' do
      let(:params) { { type: 'sensitive' } }

      it_behaves_like 'forbidden for wrong scope', 'admin:read admin:read:accounts'
      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'a successful notification delivery'
      it_behaves_like 'a successful logged action', :sensitive, :account

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'marks the target account as sensitive' do
        expect { subject }.to change { target_account.reload.sensitized? }.from(false).to(true)
      end
    end

    context 'with type of silence' do
      let(:params) { { type: 'silence' } }

      it_behaves_like 'forbidden for wrong scope', 'admin:read admin:read:accounts'
      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'a successful notification delivery'
      it_behaves_like 'a successful logged action', :silence, :account

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'marks the target account as silenced' do
        expect { subject }.to change { target_account.reload.silenced? }.from(false).to(true)
      end
    end

    context 'with type of suspend' do
      let(:params) { { type: 'suspend' } }

      it_behaves_like 'forbidden for wrong scope', 'admin:read admin:read:accounts'
      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'a successful notification delivery'
      it_behaves_like 'a successful logged action', :suspend, :account

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'marks the target account as suspended' do
        expect { subject }.to change { target_account.reload.suspended? }.from(false).to(true)
      end
    end

    context 'with type of none' do
      let(:params) { { type: 'none' } }

      it_behaves_like 'a successful notification delivery'

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end
    end

    context 'with no type' do
      let(:params) { {} }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end

    context 'with invalid type' do
      let(:params) { { type: 'invalid' } }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
      end
    end
  end
end
