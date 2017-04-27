require 'rails_helper'

describe Admin::ReportsController do
  let(:user) { Fabricate(:user, admin: true) }
  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    it 'returns http success with no filters' do
      allow(Report).to receive(:unresolved).and_return(Report.all)
      get :index

      expect(response).to have_http_status(:success)
      expect(Report).to have_received(:unresolved)
    end

    it 'returns http success with resolved filter' do
      allow(Report).to receive(:resolved).and_return(Report.all)
      get :index, params: { resolved: 1 }

      expect(response).to have_http_status(:success)
      expect(Report).to have_received(:resolved)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      report = Fabricate(:report)

      get :show, params: { id: report }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT #update' do
    describe 'with an unknown outcome' do
      it 'rejects the change' do
        report = Fabricate(:report)
        put :update, params: { id: report, outcome: 'unknown' }

        expect(response).to have_http_status(:missing)
      end
    end

    describe 'with an outcome of `resolve`' do
      it 'resolves the report' do
        report = Fabricate(:report)

        put :update, params: { id: report, outcome: 'resolve' }
        expect(response).to redirect_to(admin_report_path(report))
        report.reload
        expect(report.action_taken_by_account).to eq user.account
        expect(report.action_taken).to eq true
      end
    end

    describe 'with an outcome of `suspend`' do
      it 'suspends the reported account' do
        report = Fabricate(:report)
        allow(Admin::SuspensionWorker).to receive(:perform_async)

        put :update, params: { id: report, outcome: 'suspend' }
        expect(response).to redirect_to(admin_report_path(report))
        report.reload
        expect(report.action_taken_by_account).to eq user.account
        expect(report.action_taken).to eq true
        expect(Admin::SuspensionWorker).
          to have_received(:perform_async).with(report.target_account_id)
      end
    end

    describe 'with an outsome of `silence`' do
      it 'silences the reported account' do
        report = Fabricate(:report)

        put :update, params: { id: report, outcome: 'silence' }
        expect(response).to redirect_to(admin_report_path(report))
        report.reload
        expect(report.action_taken_by_account).to eq user.account
        expect(report.action_taken).to eq true
        expect(report.target_account).to be_silenced
      end
    end
  end
end
