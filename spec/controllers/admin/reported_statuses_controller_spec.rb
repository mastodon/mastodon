require 'rails_helper'

describe Admin::ReportedStatusesController do
  let(:user) { Fabricate(:user, admin: true) }
  before do
    sign_in user, scope: :user
  end

  describe 'DELETE #destroy' do
    it 'removes a status' do
      report = Fabricate(:report)
      status = Fabricate(:status)
      allow(RemovalWorker).to receive(:perform_async)

      delete :destroy, params: { report_id: report, id: status }
      expect(response).to redirect_to(admin_report_path(report))
      expect(RemovalWorker).
        to have_received(:perform_async).with(status.id)
    end
  end
end
