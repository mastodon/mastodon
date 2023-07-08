# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Media API', paperclip_processing: true do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'write' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'POST /api/v2/media' do
    it 'returns http success' do
      post '/api/v2/media', headers: headers, params: { file: fixture_file_upload('attachment-jpg.123456_abcd', 'image/jpeg') }
      expect(File.exist?(user.account.media_attachments.first.file.path(:small))).to be true
      expect(response).to have_http_status(200)
    end
  end
end
