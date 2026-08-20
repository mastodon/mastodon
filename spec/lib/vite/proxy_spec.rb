# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vite::Proxy do
  include Rack::Test::Methods

  subject { described_class.new(stack, config:, dev_server:) }

  let(:app) { subject }

  let(:stack) { ->(_env) { [404, { 'content-type' => 'text/plain' }, ['Not Found']] } }

  let(:config) do
    Vite::Config.new({ https: false, base_path: '/specs/' })
  end

  describe '#call' do
    context 'when the dev server is running' do
      let(:dev_server) do
        Class.new do
          def self.running?
            true
          end
        end
      end

      before do
        # This represent Vite's dev server
        stub_request(:get, "#{config.backend}/specs/app.js").to_return(status: 200, body: 'script')
      end

      it 'proxies asset requests' do
        get '/specs/app.js'
        expect(last_response.ok?).to be(true)
        expect(last_response.body).to eq('script')
      end

      it 'does not proxy other requests' do
        get '/accounts'
        expect(last_response).to have_http_status(404)
      end
    end

    context 'when the dev server is not running' do
      let(:dev_server) do
        Class.new do
          def self.running?
            false
          end
        end
      end

      it 'does not proxy asset requests' do
        get '/specs/app.js'
        expect(last_response).to have_http_status(404)
      end

      it 'does not proxy other requests' do
        get '/accounts'
        expect(last_response).to have_http_status(404)
      end
    end
  end
end
