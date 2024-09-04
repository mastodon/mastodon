# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Media Proxy' do
  describe 'GET /media_proxy/:id' do
    before { stub_attachment_request }

    context 'when attached to a status' do
      let(:status) { Fabricate(:status) }
      let(:media_attachment) { Fabricate(:media_attachment, status: status, remote_url: 'http://example.com/attachment.png') }

      it 'redirects to correct original url' do
        get "/media_proxy/#{media_attachment.id}"

        expect(response)
          .to have_http_status(302)
          .and redirect_to media_attachment.file.url(:original)
      end

      it 'redirects to small style url' do
        get "/media_proxy/#{media_attachment.id}/small"

        expect(response)
          .to have_http_status(302)
          .and redirect_to media_attachment.file.url(:small)
      end
    end

    context 'when there is not an attached status' do
      let(:media_attachment) { Fabricate(:media_attachment, status: status, remote_url: 'http://example.com/attachment.png') }

      it 'responds with missing' do
        get "/media_proxy/#{media_attachment.id}"

        expect(response)
          .to have_http_status(404)
      end
    end

    context 'when id cannot be found' do
      it 'responds with missing' do
        get '/media_proxy/missing'

        expect(response)
          .to have_http_status(404)
      end
    end

    context 'when not permitted to view' do
      let(:status) { Fabricate(:status, visibility: :direct) }
      let(:media_attachment) { Fabricate(:media_attachment, status: status, remote_url: 'http://example.com/attachment.png') }

      it 'responds with missing' do
        get "/media_proxy/#{media_attachment.id}"

        expect(response)
          .to have_http_status(404)
      end
    end

    def stub_attachment_request
      stub_request(
        :get,
        'http://example.com/attachment.png'
      )
        .to_return(
          request_fixture('avatar.txt')
        )
    end
  end
end
