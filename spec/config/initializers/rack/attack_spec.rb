# frozen_string_literal: true

require 'rails_helper'

describe Rack::Attack, type: :request do
  def app
    Rails.application
  end

  shared_examples 'throttled endpoint' do
    before do
      # Rack::Attack periods are not rolling, so avoid flaky tests by setting the time in a way
      # to avoid crossing period boundaries.

      # The code Rack::Attack uses to set periods is the following:
      # https://github.com/rack/rack-attack/blob/v6.7.0/lib/rack/attack/cache.rb#L70-L72
      # So we want to minimize `Time.now.to_i % period`

      travel_to Time.zone.at(counter_prefix * period.seconds)
    end

    context 'when the number of requests is lower than the limit' do
      before do
        below_limit.times { increment_counter }
      end

      it 'does not change the request status' do
        expect { request.call }.to change { throttle_count }.by(1)

        expect(response).to_not have_http_status(429)
      end
    end

    context 'when the number of requests is higher than the limit' do
      before do
        above_limit.times { increment_counter }
      end

      it 'returns http too many requests after limit and returns to normal status after period' do
        expect { request.call }.to change { throttle_count }.by(1)
        expect(response).to have_http_status(429)

        travel period

        expect { request.call }.to change { throttle_count }.by(1)
        expect(response).to_not have_http_status(429)
      end
    end

    def below_limit
      limit - 1
    end

    def above_limit
      limit * 2
    end

    def throttle_count
      described_class.cache.read("#{counter_prefix}:#{throttle}:#{remote_ip}") || 0
    end

    def counter_prefix
      (Time.now.to_i / period.seconds).to_i
    end

    def increment_counter
      described_class.cache.count("#{throttle}:#{remote_ip}", period)
    end
  end

  let(:remote_ip) { '1.2.3.5' }

  describe 'throttle excessive sign-up requests by IP address' do
    context 'when accessed through the website' do
      let(:throttle) { 'throttle_sign_up_attempts/ip' }
      let(:limit)  { 25 }
      let(:period) { 5.minutes }
      let(:request) { -> { post path, headers: { 'REMOTE_ADDR' => remote_ip } } }

      context 'with exact path' do
        let(:path) { '/auth' }

        it_behaves_like 'throttled endpoint'
      end

      context 'with path with format' do
        let(:path) { '/auth.html' }

        it_behaves_like 'throttled endpoint'
      end
    end

    context 'when accessed through the API' do
      let(:throttle) { 'throttle_api_sign_up' }
      let(:limit)  { 5 }
      let(:period) { 30.minutes }
      let(:request) { -> { post path, headers: { 'REMOTE_ADDR' => remote_ip } } }

      context 'with exact path' do
        let(:path) { '/api/v1/accounts' }

        it_behaves_like 'throttled endpoint'
      end

      context 'with path with format' do
        let(:path)  { '/api/v1/accounts.json' }

        it 'returns http not found' do
          request.call
          expect(response).to have_http_status(404)
        end
      end
    end
  end

  describe 'throttle excessive sign-in requests by IP address' do
    let(:throttle) { 'throttle_login_attempts/ip' }
    let(:limit)  { 25 }
    let(:period) { 5.minutes }
    let(:request) { -> { post path, headers: { 'REMOTE_ADDR' => remote_ip } } }

    context 'with exact path' do
      let(:path) { '/auth/sign_in' }

      it_behaves_like 'throttled endpoint'
    end

    context 'with path with format' do
      let(:path) { '/auth/sign_in.html' }

      it_behaves_like 'throttled endpoint'
    end
  end
end
