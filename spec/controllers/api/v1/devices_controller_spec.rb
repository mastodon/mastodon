require 'rails_helper'

RSpec.describe Api::V1::DevicesController, type: :controller do
  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'POST #register' do
    before do
      post :register, params: { registration_id: 'foo123' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'registers device' do
      expect(Device.where(account: user.account, registration_id: 'foo123').first).to_not be_nil
    end
  end

  describe 'POST #unregister' do
    before do
      post :unregister, params: { registration_id: 'foo123' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'removes device' do
      expect(Device.where(account: user.account, registration_id: 'foo123').first).to be_nil
    end
  end
end
