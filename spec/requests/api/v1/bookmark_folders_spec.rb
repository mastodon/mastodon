# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BookmarkFolders' do
  describe 'GET /api/v1/bookmark_folders' do
    subject do
      get '/api/v1/bookmark_folders', headers: headers, params: params
    end

    include_context 'with API authentication', oauth_scopes: 'read:bookmarks'

    let(:params) { {} }
    let!(:bookmark_folders) { Fabricate.times(2, :bookmark_folder, account: user.account) }

    let(:expected_response) do
      bookmark_folders.map do |folder|
        a_hash_including(id: folder.id.to_s, title: folder.title)
      end
    end

    it_behaves_like 'forbidden for wrong scope', 'write'

    it 'returns http success and the bookmark folders' do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type).to start_with('application/json')
      expect(response.parsed_body).to match_array(expected_response)
    end

    context 'with an invalid authorization header' do
      let(:headers) { { 'Authorization' => 'Bearer token_false' } }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
        expect(response.content_type).to start_with('application/json')
      end
    end
  end

  describe 'POST /api/v1/bookmark_folders' do
    subject do
      post '/api/v1/bookmark_folders', headers: headers, params: params
    end

    include_context 'with API authentication', oauth_scopes: 'write:bookmarks'

    let(:params) { { title: 'New Folder' } }

    it_behaves_like 'forbidden for wrong scope', 'read'

    it 'returns http success and creates the folder' do
      expect { subject }.to change(user.account.bookmark_folders, :count).by(1)

      expect(response).to have_http_status(200)
      expect(response.content_type).to start_with('application/json')
      expect(response.parsed_body).to include('title' => 'New Folder')
    end
  end

  describe 'PUT /api/v1/bookmark_folders/:id' do
    subject do
      put "/api/v1/bookmark_folders/#{folder.id}", headers: headers, params: params
    end

    include_context 'with API authentication', oauth_scopes: 'write:bookmarks'

    let!(:folder) { Fabricate(:bookmark_folder, account: user.account, title: 'Old Name') }
    let(:params)  { { title: 'New Name' } }

    it_behaves_like 'forbidden for wrong scope', 'read'

    it 'returns http success and updates the folder' do
      subject

      expect(response).to have_http_status(200)
      expect(folder.reload.title).to eq('New Name')
      expect(response.parsed_body).to include('title' => 'New Name')
    end
  end

  describe 'DELETE /api/v1/bookmark_folders/:id' do
    subject do
      delete "/api/v1/bookmark_folders/#{folder.id}", headers: headers
    end

    include_context 'with API authentication', oauth_scopes: 'write:bookmarks'

    let!(:folder) { Fabricate(:bookmark_folder, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'read'

    it 'returns http success and deletes the folder' do
      expect { subject }.to change(user.account.bookmark_folders, :count).by(-1)

      expect(response).to have_http_status(200)
      expect(response.parsed_body).to be_empty
    end
  end
end
