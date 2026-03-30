# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public files' do
  include RoutingHelper

  context 'when requesting service worker file' do
    it 'returns the file with the expected headers' do
      get '/sw.js'

      expect(response)
        .to have_http_status(200)

      expect(response.headers['Cache-Control'])
        .to eq "public, max-age=#{Mastodon::Middleware::PublicFileServer::SERVICE_WORKER_TTL}, must-revalidate"

      expect(response.headers['X-Content-Type-Options'])
        .to eq 'nosniff'
    end
  end

  context 'when requesting paperclip attachments', :attachment_processing do
    let(:attachment) { Fabricate(:media_attachment, type: :image) }

    it 'returns the file with the expected headers' do
      get attachment.file.url(:original)

      expect(response)
        .to have_http_status(200)

      expect(response.headers['Cache-Control'])
        .to eq "public, max-age=#{Mastodon::Middleware::PublicFileServer::CACHE_TTL}, immutable"

      expect(response.headers['Content-Security-Policy'])
        .to eq "default-src 'none'; form-action 'none'"

      expect(response.headers['X-Content-Type-Options'])
        .to eq 'nosniff'
    end
  end

  context 'when requesting other static files' do
    it 'returns the file with the expected headers' do
      get '/sounds/boop.ogg'

      expect(response)
        .to have_http_status(200)

      expect(response.headers['Cache-Control'])
        .to eq "public, max-age=#{Mastodon::Middleware::PublicFileServer::CACHE_TTL}, must-revalidate"

      expect(response.headers['X-Content-Type-Options'])
        .to eq 'nosniff'
    end
  end
end
