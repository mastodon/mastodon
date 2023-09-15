# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Admin::StatusesController do
  render_views

  let(:role)   { UserRole.find_by(name: 'Moderator') }
  let(:user)   { Fabricate(:user, role: role) }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    let(:scopes) { 'admin:read:statuses' }
    let(:status) { Fabricate(:status) }

    before do
      get :show, params: { id: status.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'read:statuses' # non-admin scope
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'DELETE #destroy' do
    let(:scopes) { 'admin:write:statuses' }
    let(:status) { Fabricate(:status) }

    before do
      post :destroy, params: { id: status.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'admin:read:statuses'
    it_behaves_like 'forbidden for wrong scope', 'write:statuses' # non-admin scope
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'removes the status' do
      expect(Status.find_by(id: status.id)).to be_nil
    end
  end

  describe 'POST #unsensitive' do
    let(:scopes) { 'admin:write:statuses' }
    let(:media)  { Fabricate(:media_attachment) }
    let(:status) { Fabricate(:status, media_attachments: [media], sensitive: true) }

    before do
      post :unsensitive, params: { id: status.id }
    end

    it_behaves_like 'forbidden for wrong scope', 'admin:read:statuses'
    it_behaves_like 'forbidden for wrong scope', 'write:statuses' # non-admin scope
    it_behaves_like 'forbidden for wrong role', ''

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'unmarks status as sensitive' do
      expect(status.reload.sensitive?).to be false
    end
  end
end
