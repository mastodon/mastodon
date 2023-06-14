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

  describe '.current' do
    it 'returns a new instance of the class' do
      pool = described_class.current

      expect(pool).to be_a(described_class)
    end

    it 'caches the instance' do
      pool = described_class.current

      expect(described_class.current).to eq(pool)
    end
  end

  describe 'Reaper' do
    subject { described_class::Reaper }

    describe '#initialize' do
      it 'sets pool and frequency values' do
        reaper = subject.new(5, 10)

        expect(reaper.pool).to eq(5)
        expect(reaper.frequency).to eq(10)
      end
    end

    describe '#run' do
      context 'with a negative frequency' do
        it 'does not run a thread loop' do
          reaper = subject.new(5, -10)

          allow(Thread).to receive(:new)
          expect(reaper.run).to be_nil
          expect(Thread).to_not have_received(:new)
        end
      end

      context 'with valid pool and frequency' do
        let(:frequency) { 10 }
        let(:pool) { instance_double(described_class) }
        let(:reaper) { subject.new(pool, frequency) }

        before do
          allow(reaper).to receive(:sleep).with(frequency)
          allow(pool).to receive(:flush).and_raise(Timeout::Error)
          allow(Thread).to receive(:new).and_yield(frequency, pool)
        end

        it 'runs a thread in a sleep/flush loop' do
          expect { reaper.run }.to raise_error(Timeout::Error)
          expect(reaper).to have_received(:sleep).with(frequency).once
          expect(pool).to have_received(:flush).once
        end
      end
    end
  end
end
