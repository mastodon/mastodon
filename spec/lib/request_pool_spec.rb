# frozen_string_literal: true

require 'rails_helper'

describe RequestPool do
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

      threads = Array.new(20) do |_i|
        Thread.new do
          20.times do
            subject.with('http://example.com') do |http_client|
              http_client.get('/').flush
            end
          end
        end
      end

      threads.map(&:join)

      expect(subject.size).to be > 1
    end

    context 'with an idle connection' do
      before do
        stub_const('RequestPool::MAX_IDLE_TIME', 0.2) # Lower the idle time limit to 0.2 seconds
        stub_const('RequestPool::REAPER_FREQUENCY', 0.1) # Run the reaper every 0.1 seconds
        stub_request(:get, 'http://example.com/').to_return(status: 200, body: 'Hello!')
      end

      it 'closes the connections' do
        subject.with('http://example.com') do |http_client|
          http_client.get('/').flush
        end

        expect { wait_for_idle_timeout }.to change(subject, :size).from(1).to(0)
      end

      def wait_for_idle_timeout
        sleep RequestPool::MAX_IDLE_TIME + 0.1 # Wait slightly longer than idle time
      end
    end
  end
end
