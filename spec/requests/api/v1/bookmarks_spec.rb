# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Bookmarks' do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'read:bookmarks' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'GET /api/v1/bookmarks' do
    subject do
      get '/api/v1/bookmarks', headers: headers, params: params
    end

    let(:params)     { {} }
    let!(:bookmarks) { Fabricate.times(3, :bookmark, account: user.account) }

    let(:expected_response) do
      bookmarks.map do |bookmark|
        a_hash_including(id: bookmark.status.id.to_s, account: a_hash_including(id: bookmark.status.account.id.to_s))
      end
    end

    it_behaves_like 'forbidden for wrong scope', 'write'

    it 'returns http success' do
      subject

      expect(response).to have_http_status(200)
    end

    it 'returns the bookmarked statuses' do
      subject

      expect(body_as_json).to match_array(expected_response)
    end

    context 'with limit param' do
      let(:params) { { limit: 2 } }

      it 'paginates correctly', :aggregate_failures do
        subject

        expect(body_as_json.size).to eq(params[:limit])
        expect(response.headers['Link'].find_link(%w(rel prev)).href).to eq(api_v1_bookmarks_url(limit: params[:limit], min_id: bookmarks.last.id))
        expect(response.headers['Link'].find_link(%w(rel next)).href).to eq(api_v1_bookmarks_url(limit: params[:limit], max_id: bookmarks[1].id))
      end
    end

    context 'without the authorization header' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
      end
    end
  end
end
