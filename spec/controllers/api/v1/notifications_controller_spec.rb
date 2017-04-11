require 'rails_helper'

RSpec.describe Api::V1::NotificationsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }
  let(:other) { Fabricate(:user, account: Fabricate(:account, username: 'bob')) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    before do
      status     = PostStatusService.new.call(user.account, 'Test')
      @reblog    = ReblogService.new.call(other.account, status)
      @mention   = PostStatusService.new.call(other.account, 'Hello @alice')
      @favourite = FavouriteService.new.call(other.account, status)
      @follow    = FollowService.new.call(other.account, 'alice')
    end

    describe 'with no options' do
      before do
        get :index
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'includes reblog' do
        expect(assigns(:notifications).map(&:activity_id)).to include(@reblog.id)
      end

      it 'includes mention' do
        expect(assigns(:notifications).map(&:activity_id)).to include(@mention.mentions.first.id)
      end

      it 'includes favourite' do
        expect(assigns(:notifications).map(&:activity_id)).to include(@favourite.id)
      end

      it 'includes follow' do
        expect(assigns(:notifications).map(&:activity_id)).to include(@follow.id)
      end
    end

    describe 'with excluded mentions' do
      before do
        get :index, params: { exclude_types: ['mention'] }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'includes reblog' do
        expect(assigns(:notifications).map(&:activity_id)).to include(@reblog.id)
      end

      it 'excludes mention' do
        expect(assigns(:notifications).map(&:activity_id)).to_not include(@mention.mentions.first.id)
      end

      it 'includes favourite' do
        expect(assigns(:notifications).map(&:activity_id)).to include(@favourite.id)
      end

      it 'includes follow' do
        expect(assigns(:notifications).map(&:activity_id)).to include(@follow.id)
      end
    end
  end
end
