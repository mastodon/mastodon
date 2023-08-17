# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::NotificationsController do
  render_views

  let(:user)  { Fabricate(:user, account_attributes: { username: 'alice' }) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:other) { Fabricate(:user) }
  let(:third) { Fabricate(:user) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    let(:scopes) { 'read:notifications' }

    it 'returns http success' do
      notification = Fabricate(:notification, account: user.account)
      get :show, params: { id: notification.id }

      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #dismiss' do
    let(:scopes) { 'write:notifications' }

    it 'destroys the notification' do
      notification = Fabricate(:notification, account: user.account)
      post :dismiss, params: { id: notification.id }

      expect(response).to have_http_status(200)
      expect { notification.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST #clear' do
    let(:scopes) { 'write:notifications' }

    it 'clears notifications for the account' do
      notification = Fabricate(:notification, account: user.account)
      post :clear

      expect(notification.account.reload.notifications).to be_empty
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #index' do
    let(:scopes) { 'read:notifications' }

    before do
      first_status = PostStatusService.new.call(user.account, text: 'Test')
      @reblog_of_first_status = ReblogService.new.call(other.account, first_status)
      mentioning_status = PostStatusService.new.call(other.account, text: 'Hello @alice')
      @mention_from_status = mentioning_status.mentions.first
      @favourite = FavouriteService.new.call(other.account, first_status)
      @second_favourite = FavouriteService.new.call(third.account, first_status)
      @follow = FollowService.new.call(other.account, user.account)
    end

    describe 'with no options' do
      before do
        get :index
      end

      it 'returns expected notification types', :aggregate_failures do
        expect(response).to have_http_status(200)

        expect(body_json_types).to include 'reblog'
        expect(body_json_types).to include 'mention'
        expect(body_json_types).to include 'favourite'
        expect(body_json_types).to include 'follow'
      end
    end

    describe 'with account_id param' do
      before do
        get :index, params: { account_id: third.account.id }
      end

      it 'returns only notifications from specified user', :aggregate_failures do
        expect(response).to have_http_status(200)

        expect(body_json_account_ids.uniq).to eq [third.account.id.to_s]
      end

      def body_json_account_ids
        body_as_json.map { |x| x[:account][:id] }
      end
    end

    describe 'with invalid account_id param' do
      before do
        get :index, params: { account_id: 'foo' }
      end

      it 'returns nothing', :aggregate_failures do
        expect(response).to have_http_status(200)

        expect(body_as_json.size).to eq 0
      end
    end

    describe 'with exclude_types param' do
      before do
        get :index, params: { exclude_types: %w(mention) }
      end

      it 'returns everything but excluded type', :aggregate_failures do
        expect(response).to have_http_status(200)

        expect(body_as_json.size).to_not eq 0
        expect(body_json_types.uniq).to_not include 'mention'
      end
    end

    describe 'with types param' do
      before do
        get :index, params: { types: %w(mention) }
      end

      it 'returns only requested type', :aggregate_failures do
        expect(response).to have_http_status(200)

        expect(body_json_types.uniq).to eq ['mention']
      end
    end

    def body_json_types
      body_as_json.pluck(:type)
    end
  end
end
