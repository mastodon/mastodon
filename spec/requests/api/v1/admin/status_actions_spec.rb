# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Status actions' do
  let(:role)    { UserRole.find_by(name: 'Moderator') }
  let(:user)    { Fabricate(:user, role: role) }
  let(:scopes)  { 'admin:write admin:write:statuses' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }
  let(:mailer)  { instance_double(ActionMailer::MessageDelivery, deliver_later!: nil) }

  before do
    allow(UserMailer).to receive(:warning).with(status.account.user, anything).and_return(mailer)
  end

  shared_examples 'a successful notification delivery' do
    it 'notifies the user about the action taken' do
      subject

      expect(UserMailer).to have_received(:warning).with(status.account.user, anything).once
      expect(mailer).to have_received(:deliver_later!).once
    end
  end

  shared_examples 'a successful logged action' do |action_type, target_type|
    it 'logs action' do
      subject

      log_item = Admin::ActionLog.where(action: action_type).last

      expect(log_item).to be_present
      expect(log_item.account_id).to eq(user.account_id)
      expect(log_item.target_id).to eq(target_type == :status ? status.id : report.id)
    end
  end

  describe 'POST /api/v1/admin/statuses/:id/action' do
    subject do
      post "/api/v1/admin/statuses/#{status.id}/action", headers: headers, params: params
    end

    let(:account) { Fabricate(:account, domain: nil) } # local account for email notification
    let(:media)   { Fabricate(:media_attachment) }
    let(:status)  { Fabricate(:status, media_attachments: [media], account: account) }

    context 'with type of delete' do
      let(:params) { { type: 'delete' } }

      it_behaves_like 'forbidden for wrong scope', 'admin:read:statuses'
      it_behaves_like 'forbidden for wrong scope', 'write:statuses' # non-admin scope
      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'a successful logged action', :destroy, :status

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'deletes the status' do
        expect { subject }.to change { Status.find_by(id: status.id) }.from(status).to(nil)
      end
    end

    context 'with type of sensitive' do
      let(:params) { { type: 'sensitive' } }

      it_behaves_like 'forbidden for wrong scope', 'admin:read:statuses'
      it_behaves_like 'forbidden for wrong scope', 'write:statuses' # non-admin scope
      it_behaves_like 'forbidden for wrong role', ''
      it_behaves_like 'a successful logged action', :update, :status

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'marks the status as sensitive' do
        expect { subject }.to change { status.reload.sensitive? }.from(false).to(true)
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

    context 'with notification delivery' do
      let(:params) { { type: 'delete', send_email_notification: true } }

      it_behaves_like 'a successful notification delivery'
    end

    context 'with report' do
      let(:report) { Fabricate(:report) }
      let(:params) { { type: 'delete', report_id: report.id } }

      it_behaves_like 'a successful logged action', :resolve, :report

      it 'resolves report' do
        expect { subject }.to change { report.reload.unresolved? }.from(true).to(false)
      end
    end
  end
end
