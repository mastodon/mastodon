# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Admin::TagsController do
  render_views

  let(:role)   { UserRole.find_by(name: 'Admin') }
  let(:user)   { Fabricate(:user, role: role) }
  let(:scopes)  { 'admin:read admin:write' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:tag) { Fabricate(:tag) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: tag.id }

      expect(response).to have_http_status(200)
    end
  end

  describe 'PUT #update' do
    let(:scopes) { 'admin:write' }

    before do
      put :update, params: { id: tag.id, display_name: tag.name.upcase }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'updates the display_name' do
      expect(tag.reload.display_name).to eq tag.name.upcase
    end

    it 'returns http unprocessable entity' do
      put :update, params: { id: tag.id, display_name: tag.name + tag.id.to_s }
      expect(response).to have_http_status 422
    end
  end
end
