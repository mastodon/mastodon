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

  describe 'POST #resolve' do
    it 'resolves the report' do
      report = Fabricate(:report)

      post :resolve, params: { id: report }
      expect(response).to redirect_to(admin_report_path(report))
      report.reload
      expect(report.action_taken_by_account).to eq user.account
      expect(report.action_taken).to eq true
    end
  end

  describe 'POST #suspend' do
    it 'suspends the reported account' do
      report = Fabricate(:report)
      allow(Admin::SuspensionWorker).to receive(:perform_async)

      post :suspend, params: { id: report }
      expect(response).to redirect_to(admin_report_path(report))
      report.reload
      expect(report.action_taken_by_account).to eq user.account
      expect(report.action_taken).to eq true
      expect(Admin::SuspensionWorker).
        to have_received(:perform_async).with(report.target_account_id)
    end
  end

  describe 'POST #silence' do
    it 'silences the reported account' do
      report = Fabricate(:report)

      post :silence, params: { id: report }
      expect(response).to redirect_to(admin_report_path(report))
      report.reload
      expect(report.action_taken_by_account).to eq user.account
      expect(report.action_taken).to eq true
      expect(report.target_account).to be_silenced
    end
  end

  describe 'POST #remove' do
    it 'removes a status' do
      report = Fabricate(:report)
      status = Fabricate(:status)
      allow(RemovalWorker).to receive(:perform_async)

      post :remove, params: { id: report, status_id: status }
      expect(response).to redirect_to(admin_report_path(report))
      expect(RemovalWorker).
        to have_received(:perform_async).with(status.id)
    end
  end
end
