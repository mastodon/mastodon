# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ReportsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let!(:status) { Fabricate(:status) }
    let!(:admin)  { Fabricate(:user, admin: true) }

    before do
      allow(AdminMailer).to receive(:new_report).and_return(double('email', deliver_later: nil))
      post :create, params: { status_ids: [status.id], account_id: status.account.id, comment: 'reasons' }
    end

    it 'creates a report' do
      expect(status.reload.account.targeted_reports).not_to be_empty
      expect(response).to have_http_status(:success)
    end

    it 'sends e-mails to admins' do
      expect(AdminMailer).to have_received(:new_report).with(admin.account, Report)
    end
  end
end
