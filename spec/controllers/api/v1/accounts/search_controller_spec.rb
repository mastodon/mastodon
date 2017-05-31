require 'rails_helper'

RSpec.describe Api::V1::Accounts::SearchController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { q: 'query' }

      expect(response).to have_http_status(:success)
    end
  end
end
