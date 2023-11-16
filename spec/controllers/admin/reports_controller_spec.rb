# frozen_string_literal: true

require 'rails_helper'

describe Admin::ReportsController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    it 'returns http success with no filters' do
      specified = Fabricate(:report, action_taken_at: nil)
      Fabricate(:report, action_taken_at: Time.now.utc)

      get :index

      expect(assigns(:reports).to_a).to have_attributes(
        size: 1,
        first: eq(specified)
      )

      expect(response)
        .to have_http_status(200)
        .and render_template(:index)
    end

    it 'returns http success with resolved filter' do
      specified = Fabricate(:report, action_taken_at: Time.now.utc)
      Fabricate(:report, action_taken_at: nil)

      get :index, params: { resolved: '1' }

      expect(assigns(:reports).to_a).to have_attributes(
        size: 1,
        first: eq(specified)
      )

      expect(response)
        .to have_http_status(200)
        .and render_template(:index)
    end
  end

  describe 'GET #show' do
    it 'renders report' do
      report = Fabricate(:report)

      get :show, params: { id: report }

      expect(assigns(:report)).to eq report

      expect(response)
        .to have_http_status(200)
        .and render_template(:show)
    end
  end

  describe 'POST #resolve' do
    it 'resolves the report' do
      report = Fabricate(:report)

      put :resolve, params: { id: report }

      expect(response)
        .to redirect_to(admin_reports_path)

      expect(report.reload).to have_attributes(
        action_taken_by_account: eq(user.account),
        action_taken?: be(true)
      )
    end
  end

  describe 'POST #reopen' do
    it 'reopens the report' do
      report = Fabricate(:report)

      put :reopen, params: { id: report }

      expect(response)
        .to redirect_to(admin_report_path(report))

      expect(report.reload).to have_attributes(
        action_taken_by_account: be_nil,
        action_taken?: be(false)
      )
    end
  end

  describe 'POST #assign_to_self' do
    it 'reopens the report' do
      report = Fabricate(:report)

      put :assign_to_self, params: { id: report }
      expect(response)
        .to redirect_to(admin_report_path(report))

      expect(report.reload.assigned_account).to eq(user.account)
    end
  end

  describe 'POST #unassign' do
    it 'reopens the report' do
      report = Fabricate(:report)

      put :unassign, params: { id: report }

      expect(response)
        .to redirect_to(admin_report_path(report))

      expect(report.reload.assigned_account).to be_nil
    end
  end
end
