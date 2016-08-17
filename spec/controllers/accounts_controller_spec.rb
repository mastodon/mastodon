require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  let(:alice)  { Fabricate(:account, username: 'alice') }

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { username: alice.username }
      expect(response).to have_http_status(:success)
    end

    it 'returns http success with Atom' do
      get :show, params: { username: alice.username }, format: 'atom'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #followers' do
    it 'returns http success' do
      get :followers, params: { username: alice.username }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #following' do
    it 'returns http success' do
      get :following, params: { username: alice.username }
      expect(response).to have_http_status(:success)
    end
  end
end
