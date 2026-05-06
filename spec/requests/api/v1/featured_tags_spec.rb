# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FeaturedTags' do
  include_context 'with API authentication', oauth_scopes: 'read:accounts write:accounts'

  describe 'GET /api/v1/featured_tags' do
    context 'with wrong scope' do
      before do
        get '/api/v1/featured_tags', headers: headers
      end

      it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    end

    context 'when Authorization header is missing' do
      it 'returns http unauthorized' do
        get '/api/v1/featured_tags'

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    it 'returns http success' do
      get '/api/v1/featured_tags', headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
    end

    context 'when the requesting user has no featured tag' do
      before { Fabricate(:featured_tag) }

      it 'returns an empty body' do
        get '/api/v1/featured_tags', headers: headers

        expect(response.parsed_body).to be_empty
      end
    end

    context 'when the requesting user has featured tags' do
      let!(:user_featured_tags) { Fabricate.times(1, :featured_tag, account: user.account) }

      it 'returns only the featured tags belonging to the requesting user' do
        get '/api/v1/featured_tags', headers: headers

        expect(response.parsed_body.pluck(:id))
          .to match_array(
            user_featured_tags.pluck(:id).map(&:to_s)
          )
      end
    end
  end

  describe 'POST /api/v1/featured_tags' do
    let(:params) { { name: 'tag' } }

    it 'returns http success and includes correct tag name' do
      post '/api/v1/featured_tags', headers: headers, params: params

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body)
        .to include(
          name: params[:name]
        )
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

    context 'when Authorization header is missing' do
      it 'returns http unauthorized' do
        post '/api/v1/featured_tags', params: params

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when required param "name" is not provided' do
      it 'returns http bad request' do
        post '/api/v1/featured_tags', headers: headers

        expect(response).to have_http_status(400)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when provided tag name is invalid' do
      let(:params) { { name: 'asj&*!' } }

      it 'returns http unprocessable entity' do
        post '/api/v1/featured_tags', headers: headers, params: params

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when tag name is already taken' do
      before do
        FeaturedTag.create(name: params[:name], account: user.account)
      end

      it 'returns http success' do
        post '/api/v1/featured_tags', headers: headers, params: params

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'DELETE /api/v1/featured_tags' do
    let!(:featured_tag) { FeaturedTag.create(name: 'tag', account: user.account) }
    let(:id) { featured_tag.id }

    it 'returns http success with an empty body and deletes the featured tag', :inline_jobs do
      delete "/api/v1/featured_tags/#{id}", headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body).to be_empty

      featured_tag = FeaturedTag.find_by(id: id)
      expect(featured_tag).to be_nil
    end

    context 'with wrong scope' do
      before do
        delete "/api/v1/featured_tags/#{id}", headers: headers
      end

      it_behaves_like 'forbidden for wrong scope', 'read:statuses'
    end

    context 'when Authorization header is missing' do
      it 'returns http unauthorized' do
        delete "/api/v1/featured_tags/#{id}"

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when featured tag with given id does not exist' do
      it 'returns http not found' do
        delete '/api/v1/featured_tags/0', headers: headers

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when deleting a featured tag of another user' do
      let!(:other_user_featured_tag) { Fabricate(:featured_tag) }
      let(:id) { other_user_featured_tag.id }

      it 'returns http not found' do
        delete "/api/v1/featured_tags/#{id}", headers: headers

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
