# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Announcements Reactions' do
  let(:user)   { Fabricate(:user) }
  let(:scopes) { 'write:favourites' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  let!(:announcement) { Fabricate(:announcement) }

  describe 'PUT /api/v1/announcements/:announcement_id/reactions/:id' do
    context 'without token' do
      it 'returns http unauthorized' do
        put "/api/v1/announcements/#{announcement.id}/reactions/#{escaped_emoji}"

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with token' do
      before do
        put "/api/v1/announcements/#{announcement.id}/reactions/#{escaped_emoji}", headers: headers
      end

      it 'creates reaction', :aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(announcement.announcement_reactions.find_by(name: '😂', account: user.account)).to_not be_nil
      end
    end
  end

  describe 'DELETE /api/v1/announcements/:announcement_id/reactions/:id' do
    before do
      announcement.announcement_reactions.create!(account: user.account, name: '😂')
    end

    context 'without token' do
      it 'returns http unauthorized' do
        delete "/api/v1/announcements/#{announcement.id}/reactions/#{escaped_emoji}"
        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'with token' do
      before do
        delete "/api/v1/announcements/#{announcement.id}/reactions/#{escaped_emoji}", headers: headers
      end

      it 'creates reaction', :aggregate_failures do
        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(announcement.announcement_reactions.find_by(name: '😂', account: user.account)).to be_nil
      end
    end
  end

  def escaped_emoji
    CGI.escape('😂')
  end
end
