# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Media' do
  include_context 'with API authentication', oauth_scopes: 'write:media'

  describe 'GET /api/v1/media/:id' do
    subject do
      get "/api/v1/media/#{media.id}", headers: headers
    end

    let(:media) { Fabricate(:media_attachment, account: user.account) }

    it_behaves_like 'forbidden for wrong scope', 'read'

    it 'returns http success with media information' do
      subject

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body).to match(
        a_hash_including(
          id: media.id.to_s,
          description: media.description,
          type: media.type
        )
      )
    end

    context 'when the media is still being processed' do
      before do
        media.update(processing: :in_progress)
      end

      it 'returns http partial content' do
        subject

        expect(response).to have_http_status(206)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when the media belongs to somebody else' do
      let(:media) { Fabricate(:media_attachment) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when media is attached to a status' do
      let(:media) { Fabricate(:media_attachment, account: user.account, status: Fabricate.build(:status)) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end
  end

  describe 'POST /api/v1/media' do
    subject do
      post '/api/v1/media', headers: headers, params: params
    end

    let(:params) { {} }

    shared_examples 'a successful media upload' do |media_type|
      it 'uploads the file successfully and returns correct media content', :aggregate_failures do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
        expect(MediaAttachment.first).to be_present
        expect(MediaAttachment.first).to have_attached_file(:file)

        expect(response.parsed_body).to match(
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

      context 'when file type cannot be identified' do
        it 'returns http unprocessable entity' do
          allow(media_attachments).to receive(:create!).and_raise(Paperclip::Errors::NotIdentifiedByImageMagickError)

          subject

          expect(response).to have_http_status(422)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end

      context 'when there is a generic error' do
        it 'returns http 500' do
          allow(media_attachments).to receive(:create!).and_raise(Paperclip::Error)

          subject

          expect(response).to have_http_status(500)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end

    context 'with image/jpeg', :attachment_processing do
      let(:params) { { file: fixture_file_upload('attachment.jpg', 'image/jpeg'), description: 'jpeg image' } }

      it_behaves_like 'a successful media upload', 'image'
    end

    context 'with image/gif', :attachment_processing do
      let(:params) { { file: fixture_file_upload('attachment.gif', 'image/gif') } }

      it_behaves_like 'a successful media upload', 'image'
    end

    context 'with video/webm', :attachment_processing do
      let(:params) { { file: fixture_file_upload('attachment.webm', 'video/webm') } }

      it_behaves_like 'a successful media upload', 'gifv'
    end
  end

  describe 'PUT /api/v1/media/:id' do
    subject do
      put "/api/v1/media/#{media.id}", headers: headers, params: params
    end

    let(:params) { {} }
    let(:media)  { Fabricate(:media_attachment, status: status, account: user.account, description: 'old') }

    it_behaves_like 'forbidden for wrong scope', 'read read:media'

    context 'when the media belongs to somebody else' do
      let(:media)  { Fabricate(:media_attachment, status: nil) }
      let(:params) { { description: 'Lorem ipsum!!!' } }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when the requesting user owns the media' do
      let(:status) { nil }
      let(:params) { { description: 'Lorem ipsum!!!' } }

      it 'updates the description' do
        expect { subject }.to change { media.reload.description }.from('old').to('Lorem ipsum!!!')
      end

      context 'when the media is attached to a status' do
        let(:status) { Fabricate(:status, account: user.account) }

        it 'returns http not found' do
          subject

          expect(response).to have_http_status(404)
          expect(response.content_type)
            .to start_with('application/json')
        end
      end
    end
  end

  describe 'DELETE /api/v1/media/:id' do
    subject do
      delete "/api/v1/media/#{media.id}", headers: headers
    end

    context 'when media is not attached to a status' do
      let(:media) { Fabricate(:media_attachment, account: user.account, status: nil) }

      it 'returns http empty response' do
        subject

        expect(response).to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')

        expect(MediaAttachment.where(id: media.id)).to_not exist
      end
    end

    context 'when media is attached to a status' do
      let(:media) { Fabricate(:media_attachment, account: user.account, status: Fabricate.build(:status)) }

      it 'returns http unprocessable entity' do
        subject

        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body).to match(
          a_hash_including(
            error: 'Media attachment is currently used by a status'
          )
        )

        expect(MediaAttachment.where(id: media.id)).to exist
      end
    end

    context 'when the media belongs to somebody else' do
      let(:media) { Fabricate(:media_attachment, status: nil) }

      it 'returns http not found' do
        subject

        expect(response).to have_http_status(404)
        expect(response.content_type)
          .to start_with('application/json')

        expect(MediaAttachment.where(id: media.id)).to exist
      end
    end
  end
end
