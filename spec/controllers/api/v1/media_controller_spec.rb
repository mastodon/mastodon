require 'rails_helper'

RSpec.describe Api::V1::MediaController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'POST #create' do
    context 'image/jpeg' do
      before do
        post :create, params: { file: fixture_file_upload('files/attachment.jpg', 'image/jpeg') }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'creates a media attachment' do
        expect(MediaAttachment.first).to_not be_nil
      end

      it 'uploads a file' do
        expect(MediaAttachment.first).to have_attached_file(:file)
      end

      it 'returns media ID in JSON' do
        expect(body_as_json[:id]).to eq MediaAttachment.first.id
      end
    end

    context 'image/gif' do
      before do
        post :create, params: { file: fixture_file_upload('files/attachment.gif', 'image/gif') }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'creates a media attachment' do
        expect(MediaAttachment.first).to_not be_nil
      end

      it 'uploads a file' do
        expect(MediaAttachment.first).to have_attached_file(:file)
      end

      it 'returns media ID in JSON' do
        expect(body_as_json[:id]).to eq MediaAttachment.first.id
      end
    end

    context 'video/webm' do
      before do
        post :create, params: { file: fixture_file_upload('files/attachment.webm', 'video/webm') }
      end

      xit 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      xit 'creates a media attachment' do
        expect(MediaAttachment.first).to_not be_nil
      end

      xit 'uploads a file' do
        expect(MediaAttachment.first).to have_attached_file(:file)
      end

      xit 'returns media ID in JSON' do
        expect(body_as_json[:id]).to eq MediaAttachment.first.id
      end
    end
  end
end
