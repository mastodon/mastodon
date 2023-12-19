# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::FiltersController do
  render_views

  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #index' do
    let(:scopes) { 'read:filters' }
    let!(:filter) { Fabricate(:custom_filter, account: user.account) }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST #create' do
    let(:scopes) { 'write:filters' }
    let(:irreversible) { true }
    let(:whole_word)   { false }

    before do
      post :create, params: { phrase: 'magic', context: %w(home), irreversible: irreversible, whole_word: whole_word }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'creates a filter' do
      filter = user.account.custom_filters.first
      expect(filter).to_not be_nil
      expect(filter.keywords.pluck(:keyword, :whole_word)).to eq [['magic', whole_word]]
      expect(filter.context).to eq %w(home)
      expect(filter.irreversible?).to be irreversible
      expect(filter.expires_at).to be_nil
    end

    context 'with different parameters' do
      let(:irreversible) { false }
      let(:whole_word)   { true }

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'creates a filter' do
        filter = user.account.custom_filters.first
        expect(filter).to_not be_nil
        expect(filter.keywords.pluck(:keyword, :whole_word)).to eq [['magic', whole_word]]
        expect(filter.context).to eq %w(home)
        expect(filter.irreversible?).to be irreversible
        expect(filter.expires_at).to be_nil
      end
    end
  end

  describe 'GET #show' do
    let(:scopes)  { 'read:filters' }
    let(:filter)  { Fabricate(:custom_filter, account: user.account) }
    let(:keyword) { Fabricate(:custom_filter_keyword, custom_filter: filter) }

    it 'returns http success' do
      get :show, params: { id: keyword.id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'PUT #update' do
    let(:scopes)  { 'write:filters' }
    let(:filter)  { Fabricate(:custom_filter, account: user.account) }
    let(:keyword) { Fabricate(:custom_filter_keyword, custom_filter: filter) }

    before do
      put :update, params: { id: keyword.id, phrase: 'updated' }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'updates the filter' do
      expect(keyword.reload.phrase).to eq 'updated'
    end
  end

  describe 'DELETE #destroy' do
    let(:scopes)  { 'write:filters' }
    let(:filter)  { Fabricate(:custom_filter, account: user.account) }
    let(:keyword) { Fabricate(:custom_filter_keyword, custom_filter: filter) }

    before do
      delete :destroy, params: { id: keyword.id }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'removes the filter' do
      expect { keyword.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
