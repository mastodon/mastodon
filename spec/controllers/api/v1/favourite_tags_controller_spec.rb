require 'rails_helper'

RSpec.describe Api::V1::FavouriteTagsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
  
  describe 'POST #create' do
    let(:tag_name) { 'dummy_tag' }
    let!(:tag) { Fabricate(:tag, name: tag_name) }

    context 'when the tag is a new favourite tag' do
      it 'create a new favourite tag and returns http success' do
        post :create, params: { tag: tag_name, visibility: 'public' }
        expect(FavouriteTag.count).to eq 4
        expect(
          JSON.parse(response.body, symbolize_names: true).except(:id)
        ).to eq ({ name: tag_name, visibility: 'public' })
        expect(response).to have_http_status(:success)
      end
    end

    context 'when the tag has already been favourite.' do
      before do
        Fabricate(:favourite_tag, account: user.account, tag: tag)
      end
      
      it 'does not create new favourite_tag and returns http 409' do
        expect {
          post :create, params: { tag: tag_name, visibility: 'private' }
        }.not_to change(FavouriteTag, :count)
        expect(
          JSON.parse(response.body, symbolize_names: true).except(:id)
        ).to eq ({ name: tag_name, visibility: 'public' })
        expect(response).to have_http_status(:conflict)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:tag_name) { 'dummy_tag' }
    let!(:tag) { Fabricate(:tag, name: tag_name) }
    
    before do
      Fabricate(:favourite_tag, account: user.account, tag: tag)
    end

    context 'when try to destroy the favourite tag' do
      it 'destroy the favourite tag and returns http success' do
        delete :destroy, params: { tag: tag_name }
        expect(FavouriteTag.count).to eq 3
        expect(response).to have_http_status(:success)
      end
    end
    
    context 'when try to destroy an unregistered tag' do
      it 'returns http 404' do
        delete :destroy, params: { tag: 'unregistered' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
