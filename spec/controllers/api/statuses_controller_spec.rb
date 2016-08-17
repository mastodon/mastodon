require 'rails_helper'

RSpec.describe Api::StatusesController, type: :controller do
  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    let(:status) { Fabricate(:status, account: user.account) }

    it 'returns http success' do
      get :show, params: { id: status.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #home' do
    it 'returns http success'
  end

  describe 'GET #mentions' do
    it 'returns http success'
  end

  describe 'POST #create' do
    it 'returns http success'
  end

  describe 'POST #reblog' do
    it 'returns http success'
  end

  describe 'POST #favourite' do
    it 'returns http success'
  end
end
