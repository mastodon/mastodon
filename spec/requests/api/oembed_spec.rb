# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API OEmbed' do
  describe 'GET /api/oembed' do
    before { host! Rails.configuration.x.local_domain }

    context 'when status is public' do
      let(:status) { Fabricate(:status, visibility: :public) }

      it 'returns success with private cache control headers' do
        get '/api/oembed', params: { url: short_account_status_url(status.account, status) }

        expect(response)
          .to have_http_status(200)
        expect(response.headers['Cache-Control'])
          .to include('private, no-store')
      end
    end

    context 'when status is not public' do
      let(:status) { Fabricate(:status, visibility: :direct) }

      it 'returns not found' do
        get '/api/oembed', params: { url: short_account_status_url(status.account, status) }

        expect(response)
          .to have_http_status(404)
      end
    end
  end
end
