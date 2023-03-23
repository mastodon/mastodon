# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::FiltersController, type: :controller do
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

    before do
      post :create, params: { title: 'magic', context: %w(home), filter_action: 'hide', keywords_attributes: [keyword: 'magic'] }
    end

    it 'returns http success' do
      expect(response).to have_http_status(200)
    end

    it 'returns a filter with keywords' do
      json = body_as_json
      expect(json[:title]).to eq 'magic'
      expect(json[:filter_action]).to eq 'hide'
      expect(json[:context]).to eq ['home']
      expect(json[:keywords].map { |keyword| keyword.slice(:keyword, :whole_word) }).to eq [{ keyword: 'magic', whole_word: true }]
    end

    it 'creates a filter' do
      filter = user.account.custom_filters.first
      expect(filter).to_not be_nil
      expect(filter.keywords.pluck(:keyword)).to eq ['magic']
      expect(filter.context).to eq %w(home)
      expect(filter.irreversible?).to be true
      expect(filter.expires_at).to be_nil
    end
  end

  describe 'GET #show' do
    let(:scopes)  { 'read:filters' }
    let(:filter)  { Fabricate(:custom_filter, account: user.account) }

    it 'returns http success' do
      get :show, params: { id: filter.id }
      expect(response).to have_http_status(200)
    end
  end

  describe 'PUT #update' do
    let(:scopes)   { 'write:filters' }
    let!(:filter)  { Fabricate(:custom_filter, account: user.account) }
    let!(:keyword) { Fabricate(:custom_filter_keyword, custom_filter: filter) }

    context 'updating filter parameters' do
      before do
        put :update, params: { id: filter.id, title: 'updated', context: %w(home public) }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'updates the filter title' do
        expect(filter.reload.title).to eq 'updated'
      end

      it 'updates the filter context' do
        expect(filter.reload.context).to eq %w(home public)
      end
    end

    context 'updating keywords in bulk' do
      before do
        allow(redis).to receive_messages(publish: nil)
        put :update, params: { id: filter.id, keywords_attributes: [{ id: keyword.id, keyword: 'updated' }] }
      end

      it 'returns http success' do
        expect(response).to have_http_status(200)
      end

      it 'updates the keyword' do
        expect(keyword.reload.keyword).to eq 'updated'
      end

      it 'sends exactly one filters_changed event' do
        expect(redis).to have_received(:publish).with("timeline:#{user.account.id}", Oj.dump(event: :filters_changed)).once
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:scopes)  { 'write:filters' }
    let(:filter)  { Fabricate(:custom_filter, account: user.account) }

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
