# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tags' do
  let(:user)    { Fabricate(:user) }
  let(:scopes)  { 'write:follows' }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/tags/:id' do
    subject do
      get "/api/v1/tags/#{name}"
    end

    context 'when the tag exists' do
      let!(:tag) { Fabricate(:tag) }
      let(:name) { tag.name }

      it 'returns the tag', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body[:name]).to eq(name)
      end
    end

    context 'when the tag does not exist' do
      let(:name) { 'hoge' }

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when the tag name is invalid' do
      let(:name) { 'tag-name' }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST /api/v1/tags/:id/follow' do
    subject do
      post "/api/v1/tags/#{name}/follow", headers: headers
    end

    let!(:tag) { Fabricate(:tag) }
    let(:name) { tag.name }

    it_behaves_like 'forbidden for wrong scope', 'read read:follows'

    context 'when the tag exists' do
      it 'creates follow', :aggregate_failures do
        subject

        expect(response).to have_http_status(:success)
        expect(response.content_type)
          .to start_with('application/json')
        expect(TagFollow.where(tag: tag, account: user.account)).to exist
      end
    end

    context 'when the tag does not exist' do
      let(:name) { 'hoge' }

      it 'creates a new tag with the specified name', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(Tag.where(name: name)).to exist
        expect(TagFollow.where(tag: Tag.find_by(name: name), account: user.account)).to exist
      end
    end

    context 'when the tag name is invalid' do
      let(:name) { 'tag-name' }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when the Authorization header is missing' do
      let(:headers) { {} }
      let(:name)    { 'unauthorized' }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST #unfollow' do
    subject do
      post "/api/v1/tags/#{name}/unfollow", headers: headers
    end

    let(:name) { tag.name }
    let!(:tag) { Fabricate(:tag, name: 'foo') }

    before do
      Fabricate(:tag_follow, account: user.account, tag: tag)
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:follows'

    it 'removes the follow', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(TagFollow.where(tag: tag, account: user.account)).to_not exist
    end

    context 'when the tag name is invalid' do
      let(:name) { 'tag-name' }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when the Authorization header is missing' do
      let(:headers) { {} }
      let(:name)    { 'unauthorized' }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST /api/v1/tags/:id/feature' do
    subject do
      post "/api/v1/tags/#{name}/feature", headers: headers
    end

    let!(:tag) { Fabricate(:tag) }
    let(:name) { tag.name }
    let(:scopes) { 'write:accounts' }

    it_behaves_like 'forbidden for wrong scope', 'read read:follows'

    context 'when the tag exists' do
      it 'creates featured tag', :aggregate_failures do
        subject

        expect(response).to have_http_status(:success)
        expect(response.content_type)
          .to start_with('application/json')
        expect(FeaturedTag.where(tag: tag, account: user.account)).to exist
      end
    end

    context 'when the tag does not exist' do
      let(:name) { 'hoge' }

      it 'creates a new tag with the specified name', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(Tag.where(name: name)).to exist
        expect(FeaturedTag.where(tag: Tag.find_by(name: name), account: user.account)).to exist
      end
    end

    context 'when the tag name is invalid' do
      let(:name) { 'tag-name' }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when the Authorization header is missing' do
      let(:headers) { {} }
      let(:name)    { 'unauthorized' }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST #unfeature' do
    subject do
      post "/api/v1/tags/#{name}/unfeature", headers: headers
    end

    let(:name) { tag.name }
    let!(:tag) { Fabricate(:tag, name: 'foo') }
    let(:scopes) { 'write:accounts' }

    before do
      Fabricate(:featured_tag, account: user.account, tag: tag)
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:follows'

    it 'removes the featured tag', :aggregate_failures do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(FeaturedTag.where(tag: tag, account: user.account)).to_not exist
    end

    context 'when the tag name is invalid' do
      let(:name) { 'tag-name' }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when the Authorization header is missing' do
      let(:headers) { {} }
      let(:name)    { 'unauthorized' }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end
end
