# frozen_string_literal: true

require 'rails_helper'

describe Admin::StatusesController do
  render_views

  let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }
  let(:account) { Fabricate(:account) }
  let!(:status) { Fabricate(:status, account: account) }
  let(:media_attached_status) { Fabricate(:status, account: account, sensitive: !sensitive) }
  let!(:media_attachment) { Fabricate(:media_attachment, account: account, status: media_attached_status) }
  let(:last_media_attached_status) { Fabricate(:status, account: account, sensitive: !sensitive) }
  let!(:last_media_attachment) { Fabricate(:media_attachment, account: account, status: last_media_attached_status) }
  let!(:last_status) { Fabricate(:status, account: account) }
  let(:sensitive) { true }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #index' do
    context do
      before do
        get :index, params: { account_id: account.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end
    end

    context 'filtering by media' do
      before do
        get :index, params: { account_id: account.id, media: '1' }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST #batch' do
    before do
      post :batch, params: { :account_id => account.id, action => '', :admin_status_batch_action => { status_ids: status_ids } }
    end

    let(:status_ids) { [media_attached_status.id] }

    context 'when action is report' do
      let(:action) { 'report' }

      it 'creates a report' do
        report = Report.last
        expect(report.target_account_id).to eq account.id
        expect(report.status_ids).to eq status_ids
      end

      it 'redirects to report page' do
        expect(response).to redirect_to(admin_report_path(Report.last.id))
      end
    end
  end
end
