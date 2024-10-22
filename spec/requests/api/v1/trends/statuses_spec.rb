# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API V1 Trends Statuses' do
  describe 'GET /api/v1/trends/statuses' do
    context 'when trends are disabled' do
      before { Setting.trends = false }

      it 'returns http success' do
        get '/api/v1/trends/statuses'

        expect(response)
          .to have_http_status(200)
          .and not_have_http_link_header
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when trends are enabled' do
      before { Setting.trends = true }

      it 'returns http success' do
        prepare_trends
        stub_const('Api::BaseController::DEFAULT_STATUSES_LIMIT', 2)
        get '/api/v1/trends/statuses'

        expect(response)
          .to have_http_status(200)
          .and have_http_link_header(api_v1_trends_statuses_url(offset: 2)).for(rel: 'next')
        expect(response.content_type)
          .to start_with('application/json')
      end

      def prepare_trends
        Fabricate.times(3, :status, trendable: true, language: 'en').each do |status|
          2.times { |i| Trends.statuses.add(status, i) }
        end
        Trends::Statuses.new(threshold: 1, decay_threshold: -1).refresh
      end

      context 'with a comically inflated external interactions count' do
        def prepare_fake_trends
          fake_remote_account = Fabricate(:account, domain: 'other.com')
          fake_status = Fabricate(:status, account: fake_remote_account, text: 'I am a big faker', trendable: true, language: 'en')
          fake_status.status_stat.tap do |status_stat|
            status_stat.reblogs_count = 0
            status_stat.favourites_count = 0
            status_stat.untrusted_reblogs_count = 1_000_000_000
            status_stat.untrusted_favourites_count = 1_000_000_000
            status_stat.save
          end
          real_remote_account = Fabricate(:account, domain: 'other.com')
          real_status = Fabricate(:status, account: real_remote_account, text: 'I make real friends online', trendable: true, language: 'en')
          real_status.status_stat.tap do |status_stat|
            status_stat.reblogs_count = 10
            status_stat.favourites_count = 10
            status_stat.untrusted_reblogs_count = 10
            status_stat.untrusted_favourites_count = 10
            status_stat.save
          end
          Trends.statuses.add(fake_status, 100)
          Trends.statuses.add(real_status, 101)
          Trends::Statuses.new(threshold: 1, decay_threshold: 1).refresh
        end

        it 'ignores the feeble attempts at deception' do
          prepare_fake_trends
          stub_const('Api::BaseController::DEFAULT_STATUSES_LIMIT', 10)
          get '/api/v1/trends/statuses'

          expect(response).to have_http_status(200)
          expect(response.parsed_body.length).to eq(1)
          expect(response.parsed_body[0]['content']).to eq('I make real friends online')
        end
      end
    end
  end
end
