require 'rails_helper'

RSpec.describe Api::V1::NotificationsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:other) { Fabricate(:user, account: Fabricate(:account, username: 'bob')) }
  let(:third) { Fabricate(:user, account: Fabricate(:account, username: 'carol')) }

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

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'includes reblog' do
        expect(assigns(:notifications).map(&:activity)).to include(@reblog_of_first_status)
      end

      it 'includes mention' do
        expect(assigns(:notifications).map(&:activity)).to include(@mention_from_status)
      end

      it 'includes favourite' do
        expect(assigns(:notifications).map(&:activity)).to include(@favourite)
      end

      it 'includes follow' do
        expect(assigns(:notifications).map(&:activity)).to include(@follow)
      end
    end

    describe 'from specified user' do
      before do
        get :index, params: { account_id: third.account.id }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'includes favourite' do
        expect(assigns(:notifications).map(&:activity)).to include(@second_favourite)
      end

      it 'excludes favourite' do
        expect(assigns(:notifications).map(&:activity)).to_not include(@favourite)
      end

      it 'excludes mention' do
        expect(assigns(:notifications).map(&:activity)).to_not include(@mention_from_status)
      end

      it 'excludes reblog' do
        expect(assigns(:notifications).map(&:activity)).to_not include(@reblog_of_first_status)
      end

      it 'excludes follow' do
        expect(assigns(:notifications).map(&:activity)).to_not include(@follow)
      end
    end

    describe 'from nonexistent user' do
      before do
        get :index, params: { account_id: 'foo' }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'excludes favourite' do
        expect(assigns(:notifications).map(&:activity)).to_not include(@favourite)
      end

      it 'excludes second favourite' do
        expect(assigns(:notifications).map(&:activity)).to_not include(@second_favourite)
      end

      it 'excludes mention' do
        expect(assigns(:notifications).map(&:activity)).to_not include(@mention_from_status)
      end

      it 'excludes reblog' do
        expect(assigns(:notifications).map(&:activity)).to_not include(@reblog_of_first_status)
      end

      it 'excludes follow' do
        expect(assigns(:notifications).map(&:activity)).to_not include(@follow)
      end
    end

    describe 'with excluded mentions' do
      before do
        get :index, params: { exclude_types: ['mention'] }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'includes reblog' do
        expect(assigns(:notifications).map(&:activity)).to include(@reblog_of_first_status)
      end

      it 'excludes mention' do
        expect(assigns(:notifications).map(&:activity)).to_not include(@mention_from_status)
      end

      it 'includes favourite' do
        expect(assigns(:notifications).map(&:activity)).to include(@favourite)
      end

      it 'includes third favourite' do
        expect(assigns(:notifications).map(&:activity)).to include(@second_favourite)
      end

      it 'includes follow' do
        expect(assigns(:notifications).map(&:activity)).to include(@follow)
      end
    end
  end
end
