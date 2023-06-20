# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ConversationsController do
  render_views

  let!(:user) { Fabricate(:user, account_attributes: { username: 'alice' }) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:other) { Fabricate(:user) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let(:scopes) { 'read:statuses' }

    before do
      PostStatusService.new.call(other.account, text: 'Hey @alice', visibility: 'direct')
      PostStatusService.new.call(user.account, text: 'Hey, nobody here', visibility: 'direct')
    end

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(200)
    end

    it 'returns pagination headers' do
      get :index, params: { limit: 1 }
      expect(response.headers['Link'].links.size).to eq(2)
    end

    it 'returns conversations' do
      get :index
      json = body_as_json
      expect(json.size).to eq 2
      expect(json[0][:accounts].size).to eq 1
    end

    context 'with since_id' do
      context 'when requesting old posts' do
        it 'returns conversations' do
          get :index, params: { since_id: Mastodon::Snowflake.id_at(1.hour.ago, with_random: false) }
          json = body_as_json
          expect(json.size).to eq 2
        end
      end

      context 'when requesting posts in the future' do
        it 'returns no conversation' do
          get :index, params: { since_id: Mastodon::Snowflake.id_at(1.hour.from_now, with_random: false) }
          json = body_as_json
          expect(json.size).to eq 0
        end
      end
    end
  end
end
