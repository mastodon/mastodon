# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V2 Filters Keywords' do
  let(:user)         { Fabricate(:user) }
  let(:token)        { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:filter)       { Fabricate(:custom_filter, account: user.account) }
  let(:other_user)   { Fabricate(:user) }
  let(:other_filter) { Fabricate(:custom_filter, account: other_user.account) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v2/filters/:filter_id/keywords' do
    let(:scopes) { 'read:filters' }
    let!(:keyword) { Fabricate(:custom_filter_keyword, custom_filter: filter) }

    it 'returns http success' do
      get "/api/v2/filters/#{filter.id}/keywords", headers: headers
      expect(response).to have_http_status(200)
      expect(response.parsed_body)
        .to contain_exactly(
          include(id: keyword.id.to_s)
        )
    end

    context "when trying to access another's user filters" do
      it 'returns http not found' do
        get "/api/v2/filters/#{other_filter.id}/keywords", headers: headers
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /api/v2/filters/:filter_id/keywords' do
    let(:scopes)    { 'write:filters' }
    let(:filter_id) { filter.id }

    before do
      post "/api/v2/filters/#{filter_id}/keywords", headers: headers, params: { keyword: 'magic', whole_word: false }
    end

    it 'creates a filter', :aggregate_failures do
      expect(response).to have_http_status(200)

      expect(response.parsed_body)
        .to include(
          keyword: 'magic',
          whole_word: false
        )

      filter = user.account.custom_filters.first
      expect(filter).to_not be_nil
      expect(filter.keywords.pluck(:keyword)).to eq ['magic']
    end

    context "when trying to add to another another's user filters" do
      let(:filter_id) { other_filter.id }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'GET /api/v2/filters/keywords/:id' do
    let(:scopes)  { 'read:filters' }
    let(:keyword) { Fabricate(:custom_filter_keyword, keyword: 'foo', whole_word: false, custom_filter: filter) }

    before do
      get "/api/v2/filters/keywords/#{keyword.id}", headers: headers
    end

    it 'responds with the keyword', :aggregate_failures do
      expect(response).to have_http_status(200)

      expect(response.parsed_body)
        .to include(
          keyword: 'foo',
          whole_word: false
        )
    end

    context "when trying to access another user's filter keyword" do
      let(:keyword) { Fabricate(:custom_filter_keyword, custom_filter: other_filter) }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'PUT /api/v2/filters/keywords/:id' do
    let(:scopes)  { 'write:filters' }
    let(:keyword) { Fabricate(:custom_filter_keyword, custom_filter: filter) }

    before do
      put "/api/v2/filters/keywords/#{keyword.id}", headers: headers, params: { keyword: 'updated' }
    end

    it 'updates the keyword', :aggregate_failures do
      expect(response).to have_http_status(200)

      expect(keyword.reload.keyword).to eq 'updated'
    end

    context "when trying to update another user's filter keyword" do
      let(:keyword) { Fabricate(:custom_filter_keyword, custom_filter: other_filter) }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'DELETE /api/v2/filters/keywords/:id' do
    let(:scopes)  { 'write:filters' }
    let(:keyword) { Fabricate(:custom_filter_keyword, custom_filter: filter) }

    before do
      delete "/api/v2/filters/keywords/#{keyword.id}", headers: headers
    end

    it 'destroys the keyword', :aggregate_failures do
      expect(response).to have_http_status(200)

      expect { keyword.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    context "when trying to update another user's filter keyword" do
      let(:keyword) { Fabricate(:custom_filter_keyword, custom_filter: other_filter) }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end
end
