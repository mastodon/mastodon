require 'rails_helper'

describe Rack::Attack do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  shared_examples 'throttled endpoint' do
    context 'when the number of requests is lower than the limit' do
      it 'does not change the request status' do
        limit.times do
          request.call
          expect(last_response.status).to_not eq(429)
        end
      end
    end

    context 'when the number of requests is higher than the limit' do
      it 'returns http too many requests' do
        (limit * 2).times do |i|
          request.call
          expect(last_response.status).to eq(429) if i > limit
        end
      end
    end
  end

  let(:remote_ip) { '1.2.3.5' }

  describe 'throttle excessive sign-up requests by IP address' do
    context 'through the website' do
      let(:limit) { 25 }
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
      let(:limit) { 5 }
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
    let(:limit) { 25 }
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
