# frozen_string_literal: true

require 'rails_helper'

describe 'FeaturedTags' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:accounts write:accounts' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  shared_examples 'forbidden for wrong scope' do |wrong_scope|
    let(:scopes) { wrong_scope }

    it 'returns http forbidden' do
      expect(response).to have_http_status(403)
    end
  end

  describe 'GET /api/v1/featured_tags' do
    context 'with wrong scope' do
      before do
        get '/api/v1/featured_tags', headers: headers
      end

      it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    end

    context 'with missing Authorization header' do
      it 'returns http unauthorized' do
        get '/api/v1/featured_tags'

        expect(response).to have_http_status(401)
      end
    end

    it 'returns http success' do
      get '/api/v1/featured_tags', headers: headers

      expect(response).to have_http_status(200)
    end

    context 'when the requesting user has no featured tag' do
      before { Fabricate.times(3, :featured_tag) }

      it 'returns an empty body' do
        get '/api/v1/featured_tags', headers: headers

        body = body_as_json

        expect(body).to be_empty
      end
    end

    context 'when the requesting user has featured tags' do
      let!(:user_featured_tags) { Fabricate.times(5, :featured_tag, account: user.account) }

      it 'returns only the featured tags belonging to the requesting user' do
        get '/api/v1/featured_tags', headers: headers

        body = body_as_json
        expected_ids = user_featured_tags.pluck(:id).map(&:to_s)

        expect(body.pluck(:id)).to match_array(expected_ids)
      end
    end
  end
end
