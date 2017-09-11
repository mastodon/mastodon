require 'rails_helper'

RSpec.describe Api::V1::FavouriteTagsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }
  let(:tag) { Fabricate(:tag, name: tag_name) }
  
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
    let(:params){
      {
        tag: tag_name,
        visibility: 'public'
      }
    }

    subject { post :create, params: params }
    
    context 'when the tag is a new favourite tag' do
      
      it 'returns http success' do
        expect { subject }.to change { user.account.favourite_tags.count }.by(1)
        expect(response).to have_http_status(:success)
      end

      it 'responce has created tag' do
        expect { subject }.to change { user.account.favourite_tags.count }.by(1)
        expect(
          JSON.parse(response.body, symbolize_names: true).except(:id)
        ).to eq ({ name: tag_name, visibility: 'public' })
      end        
    end

    context 'when the tag has already been favourite.' do
      before do
        Fabricate(:favourite_tag, account: user.account, tag: tag)
      end
      
      it 'returns http 409' do 
        expect { subject }.not_to change { user.account.favourite_tags.count }
        expect(response).to have_http_status(:conflict)
      end

      it 'does not create new favourite_tag' do
        expect { subject }.not_to change { user.account.favourite_tags.count }
        expect(
          JSON.parse(response.body, symbolize_names: true).except(:id)
        ).to eq ({ name: tag_name, visibility: 'public' })
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:params) { { tag: tag_name } }
    
    subject { delete :destroy, params: params }

    context 'when try to destroy the favourite tag' do
      let(:tag_name) { 'dummy_tag' }
      
      before do
        Fabricate(:favourite_tag, account: user.account, tag: tag)
      end
  
      it 'returns http success' do
        expect{ subject }.to change { user.account.favourite_tags.count }.by(-1)
        expect(response).to have_http_status(:success)
      end

      it 'responce has success message by json' do
        expect{ subject }.to change { user.account.favourite_tags.count }.by(-1)
        expect(
          JSON.parse(response.body, symbolize_names: true)
        ).to eq({"succeeded": true})
      end
    end
    
    context 'when try to destroy an unregistered tag' do
      let(:tag_name) { 'unregistered' }
      it 'returns http 404' do
        expect{ subject }.not_to change { user.account.favourite_tags.count }
        expect(response).to have_http_status(:not_found)
      end

      it 'responce has fail message by json' do
        expect{ subject }.not_to change { user.account.favourite_tags.count }
        expect(
          JSON.parse(response.body, symbolize_names: true)
        ).to eq({"succeeded": false})
      end
    end
  end
end
