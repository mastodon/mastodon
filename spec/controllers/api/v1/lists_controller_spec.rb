require 'rails_helper'

RSpec.describe Api::V1::ListsController, type: :controller do
  render_views

  let!(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let!(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let!(:list)  { Fabricate(:list, account: user.account) }

  before { allow(controller).to receive(:doorkeeper_token) { token } }

  describe 'GET #index' do
    let(:scopes) { 'read:lists' }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET #show' do
    let(:scopes) { 'read:lists' }

    it 'returns http success' do
      get :show, params: { id: list.id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    let(:scopes) { 'write:lists' }

    before do
      post :create, params: { title: 'Foo bar' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'creates list' do
      expect(List.where(account: user.account).count).to eq 2
      expect(List.last.title).to eq 'Foo bar'
    end
  end

  describe 'PUT #update' do
    let(:scopes) { 'write:lists' }

    before do
      put :update, params: { id: list.id, title: 'Updated title' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'updates the list' do
      expect(list.reload.title).to eq 'Updated title'
    end
  end

  describe 'DELETE #destroy' do
    let(:scopes) { 'write:lists' }

    before do
      delete :destroy, params: { id: list.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'deletes the list' do
      expect(List.find_by(id: list.id)).to be_nil
    end
  end
end
