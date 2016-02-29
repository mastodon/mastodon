require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  let(:alice)  { Fabricate(:account, username: 'alice') }

  describe 'GET #show' do
    it 'returns 200' do
      get :show, username: alice.username
      expect(response).to have_http_status(:success)
    end

    it 'returns 200 with Atom' do
      get :show, username: alice.username, format: 'atom'
      expect(response).to have_http_status(:success)
    end
  end
end
