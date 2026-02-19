# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /api/v1/accounts/relationships' do
  subject do
    get '/api/v1/accounts/relationships', headers: headers, params: params
  end

  include_context 'with API authentication', oauth_scopes: 'read:follows'

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

      expect(response)
        .to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body)
        .to be_an(Enumerable)
        .and contain_exactly(
          include(
            following: true,
            followed_by: false
          )
        )
    end
  end

  context 'when provided multiple IDs' do
    let(:params) { { id: [simon.id, lewis.id, bob.id] } }

    context 'when there is returned JSON data' do
      context 'with default parameters' do
        it 'returns an enumerable json with correct elements, excluding suspended accounts', :aggregate_failures do
          subject

          expect(response)
            .to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body)
            .to be_an(Enumerable)
            .and have_attributes(
              size: 2
            )
            .and contain_exactly(
              include(simon_item),
              include(lewis_item)
            )
        end
      end

      context 'with `with_suspended` parameter' do
        let(:params) { { id: [simon.id, lewis.id, bob.id], with_suspended: true } }

        it 'returns an enumerable json with correct elements, including suspended accounts', :aggregate_failures do
          subject

          expect(response)
            .to have_http_status(200)
          expect(response.content_type)
            .to start_with('application/json')
          expect(response.parsed_body)
            .to be_an(Enumerable)
            .and have_attributes(
              size: 3
            )
            .and contain_exactly(
              include(simon_item),
              include(lewis_item),
              include(bob_item)
            )
        end
      end

      context 'when there are duplicate IDs in the params' do
        let(:params) { { id: [simon.id, lewis.id, lewis.id, lewis.id, simon.id] } }

        it 'removes duplicate account IDs from params' do
          subject

          expect(response.parsed_body)
            .to be_an(Enumerable)
            .and have_attributes(
              size: 2
            )
            .and contain_exactly(
              include(simon_item),
              include(lewis_item)
            )
        end
      end

      def simon_item
        {
          id: simon.id.to_s,
          following: true,
          showing_reblogs: true,
          followed_by: false,
          muting: false,
          requested: false,
          domain_blocking: false,
        }
      end

      def lewis_item
        {
          id: lewis.id.to_s,
          following: false,
          showing_reblogs: false,
          followed_by: true,
          muting: false,
          requested: false,
          domain_blocking: false,
        }
      end

      def bob_item
        {
          id: bob.id.to_s,
          following: false,
          showing_reblogs: false,
          followed_by: false,
          muting: false,
          requested: false,
          domain_blocking: false,
        }
      end
    end

    it 'returns JSON with correct data on previously cached requests' do
      # Initial request including multiple accounts in params
      get '/api/v1/accounts/relationships', headers: headers, params: { id: [simon.id, lewis.id] }
      expect(response.parsed_body)
        .to have_attributes(size: 2)

      # Subsequent request with different id, should override cache from first request
      get '/api/v1/accounts/relationships', headers: headers, params: { id: [simon.id] }

      expect(response)
        .to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      expect(response.parsed_body)
        .to be_an(Enumerable)
        .and have_attributes(
          size: 1
        )
        .and contain_exactly(
          include(
            following: true,
            showing_reblogs: true
          )
        )
    end

    it 'returns JSON with correct data after change too' do
      subject
      user.account.unfollow!(simon)

      get '/api/v1/accounts/relationships', headers: headers, params: { id: [simon.id] }

      expect(response)
        .to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      expect(response.parsed_body)
        .to be_an(Enumerable)
        .and contain_exactly(
          include(
            following: false,
            showing_reblogs: false
          )
        )
    end
  end
end
