require 'rails_helper'

RSpec.describe Admin::ReportsController, type: :controller do
  describe 'GET #index' do
    before do
      sign_in Fabricate(:user, admin: true), scope: :user
    end

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
end
