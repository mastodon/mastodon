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
    it 'creates a report' do
      status = Fabricate(:status)
      post :create, params: { status_ids: [status.id], account_id: status.account.id, comment: 'reasons' }

      expect(status.reload.account.targeted_reports).not_to be_empty
      expect(response).to have_http_status(:success)
    end
  end
end
