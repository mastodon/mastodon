require 'rails_helper'

RSpec.describe Api::V1::MarkersController, type: :controller do
  render_views

  let!(:user)  { Fabricate(:user) }
  let!(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read:statuses write:statuses') }

  before { allow(controller).to receive(:doorkeeper_token) { token } }

  describe 'GET #index' do
    before do
      Fabricate(:marker, timeline: 'home', last_read_id: 123, user: user)
      Fabricate(:marker, timeline: 'notifications', last_read_id: 456, user: user)

      get :index, params: { timeline: %w(home notifications) }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns markers' do
      json = body_as_json

      expect(json.key?(:home)).to be true
      expect(json[:home][:last_read_id]).to eq '123'
      expect(json.key?(:notifications)).to be true
      expect(json[:notifications][:last_read_id]).to eq '456'
    end
  end

  describe 'POST #create' do
    context 'when no marker exists' do
      before do
        post :create, params: { home: { last_read_id: '69420' } }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'creates a marker' do
        expect(user.markers.first.timeline).to eq 'home'
        expect(user.markers.first.last_read_id).to eq 69_420
      end
    end

    context 'when a marker exists' do
      before do
        post :create, params: { home: { last_read_id: '69420' } }
        post :create, params: { home: { last_read_id: '70120' } }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'updates a marker' do
        expect(user.markers.first.timeline).to eq 'home'
        expect(user.markers.first.last_read_id).to eq 70_120
      end
    end
  end
end
