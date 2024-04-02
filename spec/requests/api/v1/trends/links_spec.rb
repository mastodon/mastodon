# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Trends Links' do
  describe 'GET /api/v1/trends/links' do
    context 'when trends are disabled' do
      before { Setting.trends = false }

      it 'returns http success' do
        get '/api/v1/trends/links'

        expect(response).to have_http_status(200)
      end
    end

    context 'when trends are enabled' do
      before { Setting.trends = true }

      it 'returns http success' do
        prepare_trends
        stub_const('Api::V1::Trends::LinksController::DEFAULT_LINKS_LIMIT', 2)
        get '/api/v1/trends/links'

        expect(response).to have_http_status(200)
        expect(response.headers).to include('Link')
      end

      def prepare_trends
        Fabricate.times(3, :preview_card, trendable: true, language: 'en').each do |link|
          2.times { |i| Trends.links.add(link, i) }
        end
        Trends::Links.new(threshold: 1).refresh
      end
    end
  end
end
