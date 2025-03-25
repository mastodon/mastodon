# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'deprecated API V1 Trends Tags' do
  describe 'GET /api/v1/trends' do
    context 'when trends are disabled' do
      before { Setting.trends = false }

      it 'returns http success' do
        get '/api/v1/trends'

        expect(response)
          .to have_http_status(200)
          .and not_have_http_link_header
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.headers['Deprecation'])
          .to start_with '@'
      end
    end

    context 'when trends are enabled' do
      before { Setting.trends = true }

      it 'returns http success' do
        prepare_trends
        stub_const('Api::V1::Trends::TagsController::DEFAULT_TAGS_LIMIT', 2)
        get '/api/v1/trends'

        expect(response)
          .to have_http_status(200)
          .and have_http_link_header(api_v1_trends_tags_url(offset: 2)).for(rel: 'next')
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.headers['Deprecation'])
          .to start_with '@'
      end

      def prepare_trends
        Fabricate.times(3, :tag, trendable: true).each do |tag|
          2.times { |i| Trends.tags.add(tag, i) }
        end
        Trends::Tags.new(threshold: 1).refresh
      end
    end
  end
end
