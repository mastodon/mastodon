# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Media', paperclip_processing: true do
  let(:user)    { Fabricate(:user) }
  let(:token)   { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)  { 'write:media' }
  let(:headers) { { 'Authorization' => "Bearer #{token.token}" } }

  describe 'POST /api/v2/media' do
    subject do
      post '/api/v2/media', headers: headers, params: params
    end

    let(:params) { {} }

    shared_examples 'a successful media upload' do |media_type|
      it 'uploads the file successfully' do
        subject

        aggregate_failures do
          expect(response).to have_http_status(200)
          expect(MediaAttachment.first).to be_present
          expect(MediaAttachment.first).to have_attached_file(:file)
        end
      end

      it 'returns the correct media content' do
        subject

        body = body_as_json

        expect(body).to match(
          a_hash_including(id: MediaAttachment.first.id.to_s, description: params[:description], type: media_type)
        )
      end
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:media'

    describe 'when paperclip errors occur' do
      let(:media_attachments) { double }
      let(:params)            { { file: fixture_file_upload('attachment.jpg', 'image/jpeg') } }

      before do
        allow(User).to receive(:find).with(token.resource_owner_id).and_return(user)
        allow(user.account).to receive(:media_attachments).and_return(media_attachments)
      end

      context 'when imagemagick cannot identify the file type' do
        it 'returns http unprocessable entity' do
          allow(media_attachments).to receive(:create!).and_raise(Paperclip::Errors::NotIdentifiedByImageMagickError)

          subject

          expect(response).to have_http_status(422)
        end
      end

      context 'when there is a generic error' do
        it 'returns http 500' do
          allow(media_attachments).to receive(:create!).and_raise(Paperclip::Error)

          subject

          expect(response).to have_http_status(500)
        end
      end
    end

    context 'with image/jpeg' do
      let(:params) { { file: fixture_file_upload('attachment.jpg', 'image/jpeg'), description: 'jpeg image' } }

      it_behaves_like 'a successful media upload', 'image'
    end

    context 'with image/gif' do
      let(:params) { { file: fixture_file_upload('attachment.gif', 'image/gif') } }

      it_behaves_like 'a successful media upload', 'image'
    end

    context "when attachment's filename includes a dot but not the expected extensions" do
      let(:params) { { file: fixture_file_upload('attachment-jpg.123456_abcd', 'image/jpeg') } }

      it_behaves_like 'a successful media upload', 'image'
    end

    context 'without an authorization header' do
      let(:headers) { {} }

      it 'returns http unauthorized' do
        subject

        expect(response).to have_http_status(401)
      end
    end
  end
end
