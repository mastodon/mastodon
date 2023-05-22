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

  describe 'POST /api/v1/featured_tags' do
    let(:params) { { name: 'tag' } }

    it 'returns http success' do
      post '/api/v1/featured_tags', headers: headers, params: params

      expect(response).to have_http_status(200)
    end

    it 'returns the correct tag name' do
      post '/api/v1/featured_tags', headers: headers, params: params

      body = body_as_json

      expect(body[:name]).to eq(params[:name])
    end

    it 'creates a new featured tag for the requesting user' do
      post '/api/v1/featured_tags', headers: headers, params: params

      featured_tag = FeaturedTag.find_by(name: params[:name], account: user.account)

      expect(featured_tag).to be_present
    end

    context 'with wrong scope' do
      before do
        post '/api/v1/featured_tags', headers: headers, params: params
      end

      it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    end

    context 'with missing Authorization header' do
      it 'returns http unauthorized' do
        post '/api/v1/featured_tags', params: params

        expect(response).to have_http_status(401)
      end
    end

    context 'when required param "name" is not provided' do
      it 'returns http bad request' do
        post '/api/v1/featured_tags', headers: headers

        expect(response).to have_http_status(400)
      end
    end

    context 'when provided tag name is invalid' do
      let(:params) { { name: 'asj&*!' } }

      it 'returns http unprocessable entity' do
        post '/api/v1/featured_tags', headers: headers, params: params

        expect(response).to have_http_status(422)
      end
    end

    context 'when tag name is already taken' do
      before do
        FeaturedTag.create(name: params[:name], account: user.account)
      end

      it 'returns http unprocessable entity' do
        post '/api/v1/featured_tags', headers: headers, params: params

        expect(response).to have_http_status(422)
      end
    end
  end
end
