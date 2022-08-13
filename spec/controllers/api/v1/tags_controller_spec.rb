require 'rails_helper'

RSpec.describe Api::V1::TagsController, type: :controller do
  render_views

  let(:user)   { Fabricate(:user) }
  let(:scopes) { 'write:follows' }
  let(:token)  { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  before { allow(controller).to receive(:doorkeeper_token) { token } }

  describe 'GET #show' do
    before do
      get :show, params: { id: name }
    end

    context 'with existing tag' do
      let!(:tag) { Fabricate(:tag) }
      let(:name) { tag.name }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end

    context 'with non-existing tag' do
      let(:name) { 'hoge' }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST #follow' do
    before do
      post :follow, params: { id: name }
    end

    context 'with existing tag' do
      let!(:tag) { Fabricate(:tag) }
      let(:name) { tag.name }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'creates follow' do
        expect(TagFollow.where(tag: tag, account: user.account).exists?).to be true
      end
    end

    context 'with non-existing tag' do
      let(:name) { 'hoge' }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'creates follow' do
        expect(TagFollow.where(tag: Tag.find_by!(name: name), account: user.account).exists?).to be true
      end
    end
  end

  describe 'POST #unfollow' do
    let!(:tag) { Fabricate(:tag, name: 'foo') }
    let!(:tag_follow) { Fabricate(:tag_follow, account: user.account, tag: tag) }

    before do
      post :unfollow, params: { id: tag.name }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'removes the follow' do
      expect(TagFollow.where(tag: tag, account: user.account).exists?).to be false
    end
  end
end
