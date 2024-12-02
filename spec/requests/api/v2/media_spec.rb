# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Media API', :attachment_processing do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'write' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'POST /api/v2/media' do
    context 'when small media format attachment is processed immediately' do
      let(:params) { { file: fixture_file_upload('attachment-jpg.123456_abcd', 'image/jpeg') } }

      it 'returns http success' do
        post '/api/v2/media', headers: headers, params: params

        expect(File.exist?(user.account.media_attachments.first.file.path(:small)))
          .to be true

        expect(response)
          .to have_http_status(200)

        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to be_a(Hash)
      end
    end

    context 'when media description is too long' do
      let(:params) do
        {
          file: fixture_file_upload('attachment-jpg.123456_abcd', 'image/jpeg'),
          description: 'aa' * MediaAttachment::MAX_DESCRIPTION_LENGTH,
        }
      end

      it 'returns http error' do
        post '/api/v2/media', headers: headers, params: params

        expect(response).to have_http_status(422)
        expect(response.body).to include 'Description is too long'
      end
    end

    context 'when large format media attachment has not been processed' do
      let(:params) { { file: fixture_file_upload('attachment.webm', 'video/webm') } }

      it 'returns http accepted' do
        post '/api/v2/media', headers: headers, params: params

        expect(File.exist?(user.account.media_attachments.first.file.path(:small)))
          .to be true

        expect(response)
          .to have_http_status(202)

        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to be_a(Hash)
      end
    end

    describe 'when paperclip errors occur' do
      let(:media_attachments) { double }
      let(:params)            { { file: fixture_file_upload('attachment.jpg', 'image/jpeg') } }

      before do
        allow(User).to receive(:find).with(token.resource_owner_id).and_return(user)
        allow(user.account).to receive(:media_attachments).and_return(media_attachments)
      end

      context 'when imagemagick cannot identify the file type' do
        before do
          allow(media_attachments).to receive(:create!).and_raise(Paperclip::Errors::NotIdentifiedByImageMagickError)
        end

        it 'returns http unprocessable entity' do
          post '/api/v2/media', headers: headers, params: params

          expect(response)
            .to have_http_status(422)

          expect(response.content_type)
            .to start_with('application/json')

          expect(response.parsed_body)
            .to be_a(Hash)
            .and include(error: /File type/)
        end
      end

      context 'when there is a generic error' do
        before do
          allow(media_attachments).to receive(:create!).and_raise(Paperclip::Error)
        end

        it 'returns http 500' do
          post '/api/v2/media', headers: headers, params: params

          expect(response)
            .to have_http_status(500)

          expect(response.content_type)
            .to start_with('application/json')

          expect(response.parsed_body)
            .to be_a(Hash)
            .and include(error: /processing/)
        end
      end
    end
  end
end
