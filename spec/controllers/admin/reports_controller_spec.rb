require 'rails_helper'

describe Admin::ReportsController do
  render_views

  let(:user) { Fabricate(:user, admin: true) }
  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    it 'returns http success with no filters' do
      specified = Fabricate(:report, action_taken: false)
      Fabricate(:report, action_taken: true)

      get :index

      reports = assigns(:reports).to_a
      expect(reports.size).to eq 1
      expect(reports[0]).to eq specified
      expect(response).to have_http_status(200)
    end

    it 'returns http success with resolved filter' do
      specified = Fabricate(:report, action_taken: true)
      Fabricate(:report, action_taken: false)

      get :index, params: { resolved: 1 }

      reports = assigns(:reports).to_a
      expect(reports.size).to eq 1
      expect(reports[0]).to eq specified

      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show' do
    it 'renders report' do
      report = Fabricate(:report)

      get :show, params: { id: report }

      expect(assigns(:report)).to eq report
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #reopen' do
    it 'reopens the report' do
      report = Fabricate(:report)

      put :reopen, params: { id: report }
      expect(response).to redirect_to(admin_report_path(report))
      report.reload
      expect(report.action_taken_by_account).to eq nil
      expect(report.action_taken).to eq false
    end
  end

  describe 'POST #assign_to_self' do
    it 'reopens the report' do
      report = Fabricate(:report)

      put :assign_to_self, params: { id: report }
      expect(response).to redirect_to(admin_report_path(report))
      report.reload
      expect(report.assigned_account).to eq user.account
    end
  end

  describe 'POST #unassign' do
    it 'reopens the report' do
      report = Fabricate(:report)

      put :unassign, params: { id: report }
      expect(response).to redirect_to(admin_report_path(report))
      report.reload
      expect(report.assigned_account).to eq nil
    end
  end
end
