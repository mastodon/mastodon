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

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      post :create, params: { user: { account_attributes: { username: 'testadmin' }, email: 'testadmin@example.com' } }
    end

    it 'redirects to accounts list page' do
      expect(response).to redirect_to admin_accounts_url
    end

    it 'creates user' do
      expect(User.find_by(email: 'testadmin@example.com')).to_not be_nil
    end
  end

  describe 'POST #create existing user' do
    let(:user) { Fabricate(:user, email: 'testadmin@example.com', account: Fabricate(:account, username: 'testadmin')) }

    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      post :create, params: { user: { account_attributes: { username: user.account.username }, email: user.email } }
    end

    it 'redirects to accounts list page' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #suspend' do
    before do
      bob.update(suspended: false)
      post :suspend, params: { id: bob.id }
    end

    it 'redirects to accounts list page' do
      expect(response).to redirect_to admin_accounts_path
    end

    it 'suspended user' do
      expect(Account.find_by(username: 'bob').suspended).to be true
    end
  end

  describe 'POST #unsuspend' do
    before do
      bob.update(suspended: true)
      post :unsuspend, params: { id: bob.id }
    end

    it 'redirects to accounts list page' do
      expect(response).to redirect_to admin_accounts_path
    end

    it 'unsuspended user' do
      expect(Account.find_by(username: 'bob').suspended).to be false
    end
  end

  describe 'POST #silence' do
    before do
      bob.update(silenced: false)
      post :silence, params: { id: bob.id }
    end

    it 'redirects to accounts list page' do
      expect(response).to redirect_to admin_accounts_path
    end

    it 'suspended user' do
      expect(Account.find_by(username: 'bob').silenced).to be true
    end
  end

  describe 'POST #unsilence' do
    before do
      bob.update(silenced: true)
      post :unsilence, params: { id: bob.id }
    end

    it 'redirects to accounts list page' do
      expect(response).to redirect_to admin_accounts_path
    end

    it 'unsilenced user' do
      expect(Account.find_by(username: 'bob').silenced).to be false
    end
  end
end
