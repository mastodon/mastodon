require 'rails_helper'

RSpec.describe Api::V1::MutesController, type: :controller do
  render_views

  let(:user)   { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:scopes) { 'read:mutes' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  before { allow(controller).to receive(:doorkeeper_token) { token } }

  describe 'GET #index' do
    it 'limits according to limit parameter' do
      2.times.map { Fabricate(:mute, account: user.account) }
      get :index, params: { limit: 1 }
      expect(body_as_json.size).to eq 1
    end

    it 'queries mutes in range according to max_id' do
      mutes = 2.times.map { Fabricate(:mute, account: user.account) }

      get :index, params: { max_id: mutes[1] }

      expect(body_as_json.size).to eq 1
      expect(body_as_json[0][:id]).to eq mutes[0].target_account_id.to_s
    end

    it 'queries mutes in range according to since_id' do
      mutes = 2.times.map { Fabricate(:mute, account: user.account) }

      get :index, params: { since_id: mutes[0] }

      expect(body_as_json.size).to eq 1
      expect(body_as_json[0][:id]).to eq mutes[1].target_account_id.to_s
    end

    it 'sets pagination header for next path' do
      mutes = 2.times.map { Fabricate(:mute, account: user.account) }
      get :index, params: { limit: 1, since_id: mutes[0] }
      expect(response.headers['Link'].find_link(['rel', 'next']).href).to eq api_v1_mutes_url(limit: 1, max_id: mutes[1])
    end

    it 'sets pagination header for previous path' do
      mute = Fabricate(:mute, account: user.account)
      get :index
      expect(response.headers['Link'].find_link(['rel', 'prev']).href).to eq api_v1_mutes_url(since_id: mute)
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(200)
    end

    context 'with wrong scopes' do
      let(:scopes) { 'write:mutes' }

      it 'returns http forbidden' do
        get :index
        expect(response).to have_http_status(403)
      end
    end
  end
end
