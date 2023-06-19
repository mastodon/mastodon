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

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'returns the tag' do
        subject

        expect(body_as_json[:name]).to eq(name)
      end
    end

    context 'when the tag does not exist' do
      let(:name) { 'hoge' }

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end
    end

    context 'when the tag name is invalid' do
      let(:name) { 'tag-name' }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
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
      it 'returns http success' do
        subject

        expect(response).to have_http_status(:success)
      end

      it 'creates follow' do
        subject

        expect(TagFollow.where(tag: tag, account: user.account)).to exist
      end
    end

    context 'when the tag does not exist' do
      let(:name) { 'hoge' }

      it 'returns http success' do
        subject

        expect(response).to have_http_status(200)
      end

      it 'creates a new tag with the specified name' do
        subject

        expect(Tag.where(name: name)).to exist
      end

      it 'creates follow' do
        subject

        expect(TagFollow.where(tag: Tag.find_by(name: name), account: user.account)).to exist
      end
    end

    context 'when the tag name is invalid' do
      let(:name) { 'tag-name' }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end

    context 'when the Authorization header is missing' do
      let(:headers) { {} }
      let(:name)    { 'unauthorized' }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
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

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'removes the follow' do
      subject

      expect(TagFollow.where(tag: tag, account: user.account)).to_not exist
    end

    context 'when the tag name is invalid' do
      let(:name) { 'tag-name' }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
      end
    end

    context 'when the Authorization header is missing' do
      let(:headers) { {} }
      let(:name)    { 'unauthorized' }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
      end
    end
  end
end
