# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AnnouncementsController do
  render_views

  let(:user)   { Fabricate(:user) }
  let(:scopes) { 'read' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  let!(:announcement) { Fabricate(:announcement) }

  describe 'GET #index' do
    context 'without token' do
      it 'returns http unprocessable entity' do
        get :index
        expect(response).to have_http_status 422
      end
    end

    context 'with token' do
      before do
        allow(controller).to receive(:doorkeeper_token) { token }
        get :index
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST #dismiss' do
    context 'without token' do
      it 'returns http unauthorized' do
        post :dismiss, params: { id: announcement.id }
        expect(response).to have_http_status 401
      end
    end

    context 'with token' do
      let(:scopes) { 'write:accounts' }

      before do
        allow(controller).to receive(:doorkeeper_token) { token }
        post :dismiss, params: { id: announcement.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'dismisses announcement' do
        expect(announcement.announcement_mutes.find_by(account: user.account)).to_not be_nil
      end
    end
  end
end
