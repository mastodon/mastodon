# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mastodon::RedisConfiguration do
  let(:redis_environment) { described_class.new }

  before do
    # We use one numbered namespace per parallel test runner
    # in the test env. This here should test the non-test
    # behavior, so we disable it temporarily.
    allow(Rails.env).to receive(:test?).and_return(false)
  end

  shared_examples 'setting a different driver' do
    context 'when setting the `REDIS_DRIVER` variable to `ruby`' do
      around do |example|
        ClimateControl.modify REDIS_DRIVER: 'ruby' do
          example.run
        end
      end

      it 'sets the driver accordingly' do
        expect(subject[:driver]).to eq :ruby
      end
    end
  end

  shared_examples 'setting a namespace' do
    context 'when setting the `REDIS_NAMESPACE` variable' do
      around do |example|
        ClimateControl.modify REDIS_NAMESPACE: 'testns' do
          example.run
        end
      end

      it 'uses the value for the namespace' do
        expect(subject[:namespace]).to eq 'testns'
      end
    end
  end

  shared_examples 'secondary configuration' do |prefix|
    context "when no `#{prefix}_REDIS_` environment variables are present" do
      it 'uses the url from the base config' do
        expect(subject[:url]).to eq 'redis://localhost:6379/0'
      end

      context 'when the base config uses sentinel' do
        around do |example|
          ClimateControl.modify REDIS_SENTINELS: '192.168.0.1:3000,192.168.0.2:4000', REDIS_SENTINEL_MASTER: 'mainsentinel' do
            example.run
          end
        end

        it 'uses the sentinel configuration from base config' do
          expect(subject[:url]).to eq 'redis://mainsentinel/0'
          expect(subject[:name]).to eq 'mainsentinel'
          expect(subject[:sentinels]).to contain_exactly({ host: '192.168.0.1', port: 3000 }, { host: '192.168.0.2', port: 4000 })
        end
      end
    end

    context "when the `#{prefix}_REDIS_URL` environment variable is present" do
      around do |example|
        ClimateControl.modify "#{prefix}_REDIS_URL": 'redis::/user@other.example.com/4' do
          example.run
        end
      end

      it 'uses the provided URL' do
        expect(subject[:url]).to eq 'redis::/user@other.example.com/4'
      end
    end

    context 'when giving separate environment variables' do
      around do |example|
        ClimateControl.modify "#{prefix}_REDIS_PASSWORD": 'testpass1', "#{prefix}_REDIS_HOST": 'redis2.example.com', "#{prefix}_REDIS_PORT": '3322', "#{prefix}_REDIS_DB": '8' do
          example.run
        end
      end

      it 'constructs the url from them' do
        expect(subject[:url]).to eq 'redis://:testpass1@redis2.example.com:3322/8'
      end
    end
  end

  shared_examples 'sentinel support' do |prefix = nil|
    prefix = prefix ? "#{prefix}_" : ''

    context 'when configuring sentinel support' do
      around do |example|
        ClimateControl.modify "#{prefix}REDIS_PASSWORD": 'testpass1', "#{prefix}REDIS_HOST": 'redis2.example.com', "#{prefix}REDIS_SENTINELS": '192.168.0.1:3000,192.168.0.2:4000', "#{prefix}REDIS_SENTINEL_MASTER": 'mainsentinel' do
          example.run
        end
      end

      it 'constructs the url using the sentinel master name' do
        expect(subject[:url]).to eq 'redis://:testpass1@mainsentinel/0'
      end

      it 'uses the redis password to authenticate with sentinels' do
        expect(subject[:sentinel_password]).to eq 'testpass1'
      end

      it 'includes the sentinel master name and list of sentinels' do
        expect(subject[:name]).to eq 'mainsentinel'
        expect(subject[:sentinels]).to contain_exactly({ host: '192.168.0.1', port: 3000 }, { host: '192.168.0.2', port: 4000 })
      end

      context "when giving dedicated credentials in `#{prefix}REDIS_SENTINEL_USERNAME` and `#{prefix}REDIS_SENTINEL_PASSWORD`" do
        around do |example|
          ClimateControl.modify "#{prefix}REDIS_SENTINEL_USERNAME": 'sentinel_user', "#{prefix}REDIS_SENTINEL_PASSWORD": 'sentinel_pass1' do
            example.run
          end
        end

        it 'uses the credential to authenticate with sentinels' do
          expect(subject[:sentinel_username]).to eq 'sentinel_user'
          expect(subject[:sentinel_password]).to eq 'sentinel_pass1'
        end
      end
    end

    context 'when giving sentinels without port numbers' do
      context "when no default port is given via `#{prefix}REDIS_SENTINEL_PORT`" do
        around do |example|
          ClimateControl.modify "#{prefix}REDIS_SENTINELS": '192.168.0.1,192.168.0.2', "#{prefix}REDIS_SENTINEL_MASTER": 'mainsentinel' do
            example.run
          end
        end

        it 'uses the default sentinel port' do
          expect(subject[:sentinels]).to contain_exactly({ host: '192.168.0.1', port: 26_379 }, { host: '192.168.0.2', port: 26_379 })
        end
      end

      context 'when adding port numbers to some, but not all sentinels' do
        around do |example|
          ClimateControl.modify "#{prefix}REDIS_SENTINELS": '192.168.0.1:5678,192.168.0.2', "#{prefix}REDIS_SENTINEL_MASTER": 'mainsentinel' do
            example.run
          end
        end

        it 'uses the given port number when available and the default otherwise' do
          expect(subject[:sentinels]).to contain_exactly({ host: '192.168.0.1', port: 5678 }, { host: '192.168.0.2', port: 26_379 })
        end
      end

      context "when a default port is given via `#{prefix}REDIS_SENTINEL_PORT`" do
        around do |example|
          ClimateControl.modify "#{prefix}REDIS_SENTINEL_PORT": '1234', "#{prefix}REDIS_SENTINELS": '192.168.0.1,192.168.0.2', "#{prefix}REDIS_SENTINEL_MASTER": 'mainsentinel' do
            example.run
          end
        end

        it 'uses the given port number' do
          expect(subject[:sentinels]).to contain_exactly({ host: '192.168.0.1', port: 1234 }, { host: '192.168.0.2', port: 1234 })
        end
      end
    end
  end

  describe '#base' do
    subject { redis_environment.base }

    context 'when no `REDIS_` environment variables are present' do
      it 'uses defaults' do
        expect(subject).to eq({
          url: 'redis://localhost:6379/0',
          driver: :hiredis,
          namespace: nil,
        })
      end
    end

    context 'when the `REDIS_URL` environment variable is present' do
      around do |example|
        ClimateControl.modify REDIS_URL: 'redis::/user@example.com/2' do
          example.run
        end
      end

      it 'uses the provided URL' do
        expect(subject).to eq({
          url: 'redis::/user@example.com/2',
          driver: :hiredis,
          namespace: nil,
        })
      end
    end

    context 'when giving separate environment variables' do
      around do |example|
        ClimateControl.modify REDIS_PASSWORD: 'testpass', REDIS_HOST: 'redis.example.com', REDIS_PORT: '3333', REDIS_DB: '3' do
          example.run
        end
      end

      it 'constructs the url from them' do
        expect(subject).to eq({
          url: 'redis://:testpass@redis.example.com:3333/3',
          driver: :hiredis,
          namespace: nil,
        })
      end
    end

    include_examples 'setting a different driver'
    include_examples 'setting a namespace'
    include_examples 'sentinel support'
  end

  describe '#sidekiq' do
    subject { redis_environment.sidekiq }

    include_examples 'secondary configuration', 'SIDEKIQ'
    include_examples 'setting a different driver'
    include_examples 'setting a namespace'
    include_examples 'sentinel support', 'SIDEKIQ'
  end

  describe '#cache' do
    subject { redis_environment.cache }

    it 'includes extra configuration' do
      expect(subject).to eq({
        url: 'redis://localhost:6379/0',
        driver: :hiredis,
        namespace: 'cache',
        expires_in: 10.minutes,
        connect_timeout: 5,
        pool: {
          size: 5,
          timeout: 5,
        },
      })
    end

    context 'when `REDIS_NAMESPACE` is not set' do
      it 'uses the `cache` namespace' do
        expect(subject[:namespace]).to eq 'cache'
      end
    end

    context 'when setting the `REDIS_NAMESPACE` variable' do
      around do |example|
        ClimateControl.modify REDIS_NAMESPACE: 'testns' do
          example.run
        end
      end

      it 'attaches the `_cache` postfix to the namespace' do
        expect(subject[:namespace]).to eq 'testns_cache'
      end
    end

    include_examples 'secondary configuration', 'CACHE'
    include_examples 'setting a different driver'
    include_examples 'sentinel support', 'CACHE'
  end
end
