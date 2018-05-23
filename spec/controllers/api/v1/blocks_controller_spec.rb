require 'rails_helper'

RSpec.describe Api::V1::BlocksController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'follow') }

  before { allow(controller).to receive(:doorkeeper_token) { token } }

  describe 'GET #index' do
    it 'limits according to limit parameter' do
      2.times.map { Fabricate(:block, account: user.account) }
      get :index, params: { limit: 1 }
      expect(body_as_json.size).to eq 1
    end

    it 'queries blocks in range according to max_id' do
      blocks = 2.times.map { Fabricate(:block, account: user.account) }

      get :index, params: { max_id: blocks[1] }

      expect(body_as_json.size).to eq 1
      expect(body_as_json[0][:id]).to eq blocks[0].target_account_id.to_s
    end

    it 'queries blocks in range according to since_id' do
      blocks = 2.times.map { Fabricate(:block, account: user.account) }

      get :index, params: { since_id: blocks[0] }

      expect(body_as_json.size).to eq 1
      expect(body_as_json[0][:id]).to eq blocks[1].target_account_id.to_s
    end

    it 'sets pagination header for next path' do
      blocks = 2.times.map { Fabricate(:block, account: user.account) }
      get :index, params: { limit: 1, since_id: blocks[0] }
      expect(response.headers['Link'].find_link(['rel', 'next']).href).to eq api_v1_blocks_url(limit: 1, max_id: blocks[1])
    end

    it 'sets pagination header for previous path' do
      block = Fabricate(:block, account: user.account)
      get :index
      expect(response.headers['Link'].find_link(['rel', 'prev']).href).to eq api_v1_blocks_url(since_id: block)
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(200)
    end
  end
end
