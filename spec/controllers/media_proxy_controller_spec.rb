# frozen_string_literal: true

require 'rails_helper'

describe MediaProxyController do
  render_views

  before do
    stub_request(:get, 'http://example.com/attachment.png').to_return(request_fixture('avatar.txt'))
  end

  describe '#show' do
    it 'redirects when attached to a status' do
      status = Fabricate(:status)
      media_attachment = Fabricate(:media_attachment, status: status, remote_url: 'http://example.com/attachment.png')
      get :show, params: { id: media_attachment.id }

      expect(response).to have_http_status(302)
    end

    it 'responds with missing when there is not an attached status' do
      media_attachment = Fabricate(:media_attachment, status: nil, remote_url: 'http://example.com/attachment.png')
      get :show, params: { id: media_attachment.id }

      expect(response).to have_http_status(404)
    end

    it 'raises when id cant be found' do
      get :show, params: { id: 'missing' }

      expect(response).to have_http_status(404)
    end

    it 'raises when not permitted to view' do
      status = Fabricate(:status, visibility: :direct)
      media_attachment = Fabricate(:media_attachment, status: status, remote_url: 'http://example.com/attachment.png')
      get :show, params: { id: media_attachment.id }

      expect(response).to have_http_status(404)
    end
  end

  describe '#short' do
    it 'redirects to the original url' do
      media_attachment = Fabricate(:media_attachment)
      token = media_attachment.generate_token
      get :short, params: { id: token.id }

      expect(response).to have_http_status(302)
      expect(response.headers['Location']).to match(media_attachment.file.url(:original))
    end
  end
end
