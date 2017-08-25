require 'rails_helper'

RSpec.describe Settings::FavouriteTagsController, type: :controller do
  render_views

  before do
    @user = Fabricate(:user)
    sign_in @user, scope: :user
  end

  describe "GET #index" do
    before do
      get :index
    end

    it 'assigns @favourite_tag' do
      expect(assigns(:favourite_tag)).to be_kind_of FavouriteTag
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PUT #create' do
    let!(:tag)     { Fabricate(:tag, name: 'dummy_tag') }
    let!(:favourite_tag) { Fabricate(:favourite_tag, account: @user.account, tag: tag) }

    it 'create the favourite tag' do
      params = {
        favourite_tag: {
          tag_attributes: {
            name: 'test_tag'
          },
          visibility: 'public'
        }
      }

      post :create, params: params
      expect(response).to redirect_to(settings_favourite_tags_path)
      expect(FavouriteTag.count).to eq 2
    end

    it 'redirect index for existent favourite tag' do
      params = {
        favourite_tag: {
          tag_attributes: {
            name: 'dummy_tag'
          },
          visibility: 'public'
        }
      }

      post :create, params: params
      expect(response).to render_template(:index)
      expect(FavouriteTag.count).to eq 1
    end
  end

  describe 'PUT #destroy' do
    let!(:tag)     { Fabricate(:tag, name: 'dummy_tag') }
    let!(:favourite_tag) { Fabricate(:favourite_tag, account: @user.account, tag: tag) }

    it 'destroy the favourite tag' do
      delete :destroy, params: { id: favourite_tag.id }
      expect(response).to redirect_to(settings_favourite_tags_path)
      expect(FavouriteTag.count).to eq 0
    end
  end
end
