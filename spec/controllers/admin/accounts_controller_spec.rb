require 'rails_helper'

RSpec.describe Admin::AccountsController, type: :controller do
  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  let(:bob) { Fabricate(:account, username: 'bob') }

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: { id: bob.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { id: bob.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #update email only' do
    let(:user) { Fabricate(:user, email: 'bob@example.com', account: bob) }

    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      post :update,  params: { id: user.account.id, user: { email: 'newbob@example.com' } }
    end

    it 'redirects to account page' do
      expect(response).to redirect_to admin_account_url(user.account.id)
    end

    it 'saved mail' do
      expect(User.find_by(id: user.id).email).to eq('newbob@example.com')
    end
  end

  describe 'POST #update with password' do
    let(:user) { Fabricate(:user, email: 'bob@example.com', account: bob) }

    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      post :update,  params: { id: user.account.id, user: { password: '12345678', password_confirmation: '12345678' } }
    end

    it 'redirects to account page' do
      expect(response).to redirect_to admin_account_url(user.account.id)
    end
  end

  describe 'POST #update with password confirmation error' do
    let(:user) { Fabricate(:user, email: 'bob@example.com', account: bob) }

    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      post :update,  params: { id: user.account.id, user: { password: '12345678', password_confirmation: '123456789' } }
    end

    it 'stay on edit page' do
      expect(response).to have_http_status(:success)
    end
  end
end
