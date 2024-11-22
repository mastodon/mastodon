# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestPool do
  subject { described_class.new }

  describe '#with' do
    it 'returns a HTTP client for a host' do
      subject.with('http://example.com') do |http_client|
        expect(http_client).to be_a HTTP::Client
      end
    end

    it 'returns the same instance of HTTP client within the same thread for the same host' do
      test_client = nil

      subject.with('http://example.com') { |http_client| test_client = http_client }
      expect(test_client).to_not be_nil
      subject.with('http://example.com') { |http_client| expect(http_client).to be test_client }
    end

    it 'returns different HTTP clients for different hosts' do
      test_client = nil

      subject.with('http://example.com') { |http_client| test_client = http_client }
      expect(test_client).to_not be_nil
      subject.with('http://example.org') { |http_client| expect(http_client).to_not be test_client }
    end

    it 'grows to the number of threads accessing it' do
      stub_request(:get, 'http://example.com/').to_return(status: 200, body: 'Hello!')

      subject

      multi_threaded_execution(5) do
        subject.with('http://example.com') do |http_client|
          http_client.get('/').flush
          # Nudge scheduler to yield and exercise the full pool
          sleep(0.01)
        end
      end

      expect(subject.size).to be > 1
    end

    context 'with an idle connection' do
      before do
        stub_const('RequestPool::MAX_IDLE_TIME', 1) # Lower idle time limit to 1 seconds
        stub_const('RequestPool::REAPER_FREQUENCY', 0.1) # Run reaper every 0.1 seconds
        stub_request(:get, 'http://example.com/').to_return(status: 200, body: 'Hello!')
      end

      it 'closes the connections' do
        subject.with('http://example.com') do |http_client|
          http_client.get('/').flush
        end

        expect { reaper_observes_idle_timeout }.to change(subject, :size).from(1).to(0)
      end

      def reaper_observes_idle_timeout
        # One full idle period and 2 reaper cycles more
        sleep RequestPool::MAX_IDLE_TIME + (RequestPool::REAPER_FREQUENCY * 2)
      end
    end
  end
end
