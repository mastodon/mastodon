# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Trends Statuses' do
  describe 'GET /api/v1/trends/statuses' do
    context 'when trends are disabled' do
      before { Setting.trends = false }

      it 'returns http success' do
        get '/api/v1/trends/statuses'

        expect(response).to have_http_status(200)
      end
    end

    context 'when trends are enabled' do
      before { Setting.trends = true }

      it 'returns http success' do
        prepare_trends
        stub_const('Api::BaseController::DEFAULT_STATUSES_LIMIT', 2)
        get '/api/v1/trends/statuses'

        expect(response).to have_http_status(200)
        expect(response.headers).to include('Link')
      end

      def prepare_trends
        Fabricate.times(3, :status, trendable: true, language: 'en').each do |status|
          2.times { |i| Trends.statuses.add(status, i) }
        end
        Trends::Statuses.new(threshold: 1, decay_threshold: -1).refresh
      end
    end
  end
end
