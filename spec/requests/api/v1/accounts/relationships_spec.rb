# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/v1/accounts/relationships' do
  subject do
    get '/api/v1/accounts/relationships', headers: headers, params: params
  end

  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'read:follows' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  let(:simon) { Fabricate(:account) }
  let(:lewis) { Fabricate(:account) }

  before do
    user.account.follow!(simon)
    lewis.follow!(user.account)
  end

  context 'when provided only one ID' do
    let(:params) { { id: simon.id } }

    it 'returns JSON with correct data', :aggregate_failures do
      subject

      json = body_as_json

      expect(response).to have_http_status(200)
      expect(json).to be_a Enumerable
      expect(json.first[:following]).to be true
      expect(json.first[:followed_by]).to be false
    end
  end

  context 'when provided multiple IDs' do
    let(:params) { { id: [simon.id, lewis.id] } }

    context 'when there is returned JSON data' do
      let(:json) { body_as_json }

      it 'returns an enumerable json with correct elements', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(json).to be_a Enumerable

        expect_simon_item_one
        expect_lewis_item_two
      end

      def expect_simon_item_one
        expect(json.first[:id]).to eq simon.id.to_s
        expect(json.first[:following]).to be true
        expect(json.first[:showing_reblogs]).to be true
        expect(json.first[:followed_by]).to be false
        expect(json.first[:muting]).to be false
        expect(json.first[:requested]).to be false
        expect(json.first[:domain_blocking]).to be false
      end

      def expect_lewis_item_two
        expect(json.second[:id]).to eq lewis.id.to_s
        expect(json.second[:following]).to be false
        expect(json.second[:showing_reblogs]).to be false
        expect(json.second[:followed_by]).to be true
        expect(json.second[:muting]).to be false
        expect(json.second[:requested]).to be false
        expect(json.second[:domain_blocking]).to be false
      end
    end

    it 'returns JSON with correct data on cached requests too' do
      subject
      subject

      expect(response).to have_http_status(200)

      json = body_as_json

      expect(json).to be_a Enumerable
      expect(json.first[:following]).to be true
      expect(json.first[:showing_reblogs]).to be true
    end

    it 'returns JSON with correct data after change too' do
      subject
      user.account.unfollow!(simon)

      get '/api/v1/accounts/relationships', headers: headers, params: { id: [simon.id] }

      expect(response).to have_http_status(200)

      json = body_as_json

      expect(json).to be_a Enumerable
      expect(json.first[:following]).to be false
      expect(json.first[:showing_reblogs]).to be false
    end
  end
end
