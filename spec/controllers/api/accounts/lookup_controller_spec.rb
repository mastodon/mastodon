require 'rails_helper'

RSpec.describe Api::Accounts::LookupController, type: :controller do
  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    before do
      Fabricate(:account, username: 'bob')
      Fabricate(:account, username: 'mcbeth')
      get :index, usernames: 'alice,bob,mcbeth'
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end
end
