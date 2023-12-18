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
  let(:bob)   { Fabricate(:account, suspended: true) }

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
    let(:params) { { id: [simon.id, lewis.id, bob.id] } }

    context 'when there is returned JSON data' do
      let(:json) { body_as_json }

      context 'with default parameters' do
        it 'returns an enumerable json with correct elements, excluding suspended accounts', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(json).to be_a Enumerable
          expect(json.size).to eq 2

          expect_simon_item_one
          expect_lewis_item_two
        end
      end

      context 'with `with_suspended` parameter' do
        let(:params) { { id: [simon.id, lewis.id, bob.id], with_suspended: true } }

        it 'returns an enumerable json with correct elements, including suspended accounts', :aggregate_failures do
          subject

          expect(response).to have_http_status(200)
          expect(json).to be_a Enumerable
          expect(json.size).to eq 3

          expect_simon_item_one
          expect_lewis_item_two
          expect_bob_item_three
        end
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

      def expect_bob_item_three
        expect(json.third[:id]).to eq bob.id.to_s
        expect(json.third[:following]).to be false
        expect(json.third[:showing_reblogs]).to be false
        expect(json.third[:followed_by]).to be false
        expect(json.third[:muting]).to be false
        expect(json.third[:requested]).to be false
        expect(json.third[:domain_blocking]).to be false
      end
    end

    it 'returns JSON with correct data on previously cached requests' do
      # Initial request including multiple accounts in params
      get '/api/v1/accounts/relationships', headers: headers, params: { id: [simon.id, lewis.id] }
      expect(body_as_json.size).to eq(2)

      # Subsequent request with different id, should override cache from first request
      get '/api/v1/accounts/relationships', headers: headers, params: { id: [simon.id] }

      expect(response).to have_http_status(200)

      expect(body_as_json)
        .to be_an(Enumerable)
        .and have_attributes(
          size: 1,
          first: hash_including(
            following: true,
            showing_reblogs: true
          )
        )
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
