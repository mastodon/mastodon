# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Announcements' do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'read' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  let!(:announcement) { Fabricate(:announcement) }

  describe 'GET /api/v1/announcements' do
    context 'without token' do
      it 'returns http unprocessable entity' do
        get '/api/v1/announcements'

        expect(response).to have_http_status 422
      end
    end

    context 'with token' do
      before do
        get '/api/v1/announcements', headers: headers
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'POST /api/v1/announcements/:id/dismiss' do
    context 'without token' do
      it 'returns http unauthorized' do
        post "/api/v1/announcements/#{announcement.id}/dismiss"

        expect(response).to have_http_status 401
      end
    end

    context 'with token' do
      let(:scopes) { 'write:accounts' }

      before do
        post "/api/v1/announcements/#{announcement.id}/dismiss", headers: headers
      end

      it 'dismisses announcement', :aggregate_failures do
        expect(response).to have_http_status(200)
        expect(announcement.announcement_mutes.find_by(account: user.account)).to_not be_nil
      end
    end
  end
end
