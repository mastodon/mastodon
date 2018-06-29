require 'rails_helper'

RSpec.describe Api::V1::FiltersController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read write') }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let!(:filter) { Fabricate(:custom_filter, account: user.account) }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    before do
      post :create, params: { phrase: 'magic', context: %w(home), irreversible: true }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'creates a filter' do
      filter = user.account.custom_filters.first
      expect(filter).to_not be_nil
      expect(filter.phrase).to eq 'magic'
      expect(filter.context).to eq %w(home)
      expect(filter.irreversible?).to be true
      expect(filter.expires_at).to be_nil
    end
  end

  describe 'GET #show' do
    let(:filter) { Fabricate(:custom_filter, account: user.account) }

    it 'returns http success' do
      get :show, params: { id: filter.id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'PUT #update' do
    let(:filter) { Fabricate(:custom_filter, account: user.account) }

    before do
      put :update, params: { id: filter.id, phrase: 'updated' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'updates the filter' do
      expect(filter.reload.phrase).to eq 'updated'
    end
  end

  describe 'DELETE #destroy' do
    let(:filter) { Fabricate(:custom_filter, account: user.account) }

    before do
      delete :destroy, params: { id: filter.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'removes the filter' do
      expect { filter.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
