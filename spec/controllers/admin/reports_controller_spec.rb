# frozen_string_literal: true

require 'rails_helper'

describe Admin::ReportsController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    # This isn't the primary entrypoint anymore, as navigation links with the
    # status=unresolved filter applied.
    it 'redirects if no filters are supplied' do
      get :index

      expect(response)
        .to redirect_to admin_reports_path({ status: 'unresolved' })
    end

    it 'returns http success with status filter of unresolved' do
      specified = Fabricate(:report, action_taken_at: nil)
      Fabricate(:report, action_taken_at: Time.now.utc)

      get :index, params: { status: 'unresolved' }

      reports = assigns(:reports).to_a
      expect(reports.size).to eq 1
      expect(reports[0]).to eq specified
      expect(response).to have_http_status(200)
    end

    it 'returns http success with status filter of resolved' do
      specified = Fabricate(:report, action_taken_at: Time.now.utc)
      Fabricate(:report, action_taken_at: nil)

      get :index, params: { status: 'resolved' }

      reports = assigns(:reports).to_a
      expect(reports.size).to eq 1
      expect(reports[0]).to eq specified

      expect(response).to have_http_status(200)
    end

    it 'returns http success with status filter of all' do
      resolved = Fabricate(:report, action_taken_at: Time.now.utc)
      unresolved = Fabricate(:report, action_taken_at: nil)

      get :index, params: { status: 'all' }

      reports = assigns(:reports).to_a
      expect(reports.size).to eq 2

      # unresolved is the most recently created report, so it's first:
      expect(reports[0]).to eq unresolved
      expect(reports[1]).to eq resolved

      expect(response).to have_http_status(200)
    end

    it 'returns http success with target_account_id filter' do
      targeted_account = Fabricate(:account)
      not_targeted_account = Fabricate(:account)

      targeted = Fabricate(:report, action_taken_at: nil, target_account: targeted_account)
      Fabricate(:report, action_taken_at: nil, target_account: not_targeted_account)

      get :index, params: { target_account_id: targeted_account.id }

      reports = assigns(:reports).to_a
      expect(reports.size).to eq 1
      expect(reports[0]).to eq targeted

      expect(response).to have_http_status(200)
    end

    describe 'outdated filters' do
      # As we're changing how the report search field works, we need to ensure we
      # don't break anyone's existing searches:
      it 'redirects if by_target_domain is used' do
        get :index, params: { by_target_domain: 'social.example' }

        expect(response)
          .to redirect_to admin_reports_path({ search_type: 'target', search_term: 'social.example', status: 'unresolved' })
      end

      it 'redirects if resolved is used' do
        get :index, params: { resolved: '1' }

        expect(response)
          .to redirect_to admin_reports_path({ search_type: 'target', search_term: nil, status: 'resolved' })
      end

      it 'redirects if resolved and by_target_domain are used' do
        get :index, params: { resolved: '1', by_target_domain: 'social.example' }

        expect(response).to redirect_to admin_reports_path({
          search_type: 'target',
          search_term: 'social.example',
          status: 'resolved',
        })
      end
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

  describe 'POST #resolve' do
    it 'resolves the report' do
      report = Fabricate(:report)

      put :resolve, params: { id: report }
      expect(response).to redirect_to(admin_reports_path)
      report.reload
      expect(report.action_taken_by_account).to eq user.account
      expect(report.action_taken?).to be true
      expect(last_action_log.target).to eq(report)
    end
  end

  describe 'POST #reopen' do
    it 'reopens the report' do
      report = Fabricate(:report, action_taken_at: 3.days.ago)

      put :reopen, params: { id: report }
      expect(response).to redirect_to(admin_report_path(report))
      report.reload
      expect(report.action_taken_by_account).to be_nil
      expect(report.action_taken?).to be false
      expect(last_action_log.target).to eq(report)
    end
  end

  describe 'POST #assign_to_self' do
    it 'reopens the report' do
      report = Fabricate(:report)

      put :assign_to_self, params: { id: report }
      expect(response).to redirect_to(admin_report_path(report))
      report.reload
      expect(report.assigned_account).to eq user.account
      expect(last_action_log.target).to eq(report)
    end
  end

  describe 'POST #unassign' do
    it 'reopens the report' do
      report = Fabricate(:report, assigned_account_id: Account.last.id)

      put :unassign, params: { id: report }
      expect(response).to redirect_to(admin_report_path(report))
      report.reload
      expect(report.assigned_account).to be_nil
      expect(last_action_log.target).to eq(report)
    end
  end

  private

  def last_action_log
    Admin::ActionLog.last
  end
end
