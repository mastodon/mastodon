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
      first_status = PostStatusService.new.call(user.account, 'Test')
      @reblog_of_first_status = ReblogService.new.call(other.account, first_status)
      mentioning_status = PostStatusService.new.call(other.account, 'Hello @alice')
      @mention_from_status = mentioning_status.mentions.first
      @favourite = FavouriteService.new.call(other.account, first_status)
      @follow = FollowService.new.call(other.account, 'alice')
    end

    describe 'with no options' do
      before do
        get :index
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
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

    describe 'with excluded mentions' do
      before do
        get :index, params: { exclude_types: ['mention'] }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
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

      it 'includes follow' do
        expect(assigns(:notifications).map(&:activity)).to include(@follow)
      end
    end
  end
end
