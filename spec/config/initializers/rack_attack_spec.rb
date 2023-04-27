# frozen_string_literal: true

require 'rails_helper'

describe Rack::Attack do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  shared_examples 'throttled endpoint' do
    before do
      # Rack::Attack periods are not rolling, so avoid flaky tests by setting the time in a way
      # to avoid crossing period boundaries.

      # The code Rack::Attack uses to set periods is the following:
      # https://github.com/rack/rack-attack/blob/v6.6.1/lib/rack/attack/cache.rb#L64-L66
      # So we want to minimize `Time.now.to_i % period`

      travel_to Time.zone.at((Time.now.to_i / period.seconds).to_i * period.seconds)
    end

    context 'when the number of requests is lower than the limit' do
      it 'does not change the request status' do
        limit.times do
          request.call
          expect(last_response.status).to_not eq(429)
        end
      end
    end

    context 'when the number of requests is higher than the limit' do
      it 'returns http too many requests after limit and returns to normal status after period' do
        (limit * 2).times do |i|
          request.call
          expect(last_response.status).to eq(429) if i > limit
        end

        travel period

        request.call
        expect(last_response.status).to_not eq(429)
      end
    end
  end

  let(:remote_ip) { '1.2.3.5' }

  describe 'throttle excessive sign-up requests by IP address' do
    context 'through the website' do
      let(:limit)  { 25 }
      let(:period) { 5.minutes }
      let(:request) { -> { post path, {}, 'REMOTE_ADDR' => remote_ip } }

      context 'for exact path' do
        let(:path) { '/auth' }

        it_behaves_like 'throttled endpoint'
      end

      context 'for path with format' do
        let(:path) { '/auth.html' }

        it_behaves_like 'throttled endpoint'
      end
    end

    context 'through the API' do
      let(:limit)  { 5 }
      let(:period) { 30.minutes }
      let(:request) { -> { post path, {}, 'REMOTE_ADDR' => remote_ip } }

      context 'for exact path' do
        let(:path) { '/api/v1/accounts' }

        it_behaves_like 'throttled endpoint'
      end

      context 'for path with format' do
        let(:path)  { '/api/v1/accounts.json' }

        it 'returns http not found' do
          request.call
          expect(last_response.status).to eq(404)
        end
      end
    end
  end

  describe 'throttle excessive sign-in requests by IP address' do
    let(:limit)  { 25 }
    let(:period) { 5.minutes }
    let(:request) { -> { post path, {}, 'REMOTE_ADDR' => remote_ip } }

    context 'for exact path' do
      let(:path) { '/auth/sign_in' }

      it_behaves_like 'throttled endpoint'
    end

    context 'for path with format' do
      let(:path) { '/auth/sign_in.html' }

      it_behaves_like 'throttled endpoint'
    end
  end
end
