require 'rails_helper'

describe Admin::ReportedStatusesController do
  render_views

  let(:user) { Fabricate(:user, admin: true) }
  let(:report) { Fabricate(:report, status_ids: [status.id]) }
  let(:status) { Fabricate(:status) }

  before do
    sign_in user, scope: :user
  end

  describe 'POST #create' do
    subject do
      -> { post :create, params: { report_id: report, form_status_batch: { action: action, status_ids: status_ids } } }
    end

    let(:action) { 'nsfw_on' }
    let(:status_ids) { [status.id] }
    let(:status) { Fabricate(:status, sensitive: !sensitive) }
    let(:sensitive) { true }
    let!(:media_attachment) { Fabricate(:media_attachment, status: status) }

    context 'updates sensitive column to true' do
      it 'updates sensitive column' do
        is_expected.to change {
          status.reload.sensitive
        }.from(false).to(true)
      end
    end

    context 'updates sensitive column to false' do
      let(:action) { 'nsfw_off' }
      let(:sensitive) { false }

      it 'updates sensitive column' do
        is_expected.to change {
          status.reload.sensitive
        }.from(true).to(false)
      end
    end

    it 'redirects to report page' do
      subject.call
      expect(response).to redirect_to(admin_report_path(report))
    end
  end

  describe 'PATCH #update' do
    subject do
      -> { patch :update, params: { report_id: report, id: status, status: { sensitive: sensitive } } }
    end

    let(:status) { Fabricate(:status, sensitive: !sensitive) }
    let(:sensitive) { true }

    context 'updates sensitive column to true' do
      it 'updates sensitive column' do
        is_expected.to change {
          status.reload.sensitive
        }.from(false).to(true)
      end
    end

    context 'updates sensitive column to false' do
      let(:sensitive) { false }

      it 'updates sensitive column' do
        is_expected.to change {
          status.reload.sensitive
        }.from(true).to(false)
      end
    end

    it 'redirects to report page' do
      subject.call
      expect(response).to redirect_to(admin_report_path(report))
    end
  end

  describe 'DELETE #destroy' do
    it 'removes a status' do
      allow(RemovalWorker).to receive(:perform_async)

      delete :destroy, params: { report_id: report, id: status }
      expect(response).to have_http_status(:success)
      expect(RemovalWorker).
        to have_received(:perform_async).with(status.id)
    end
  end
end
