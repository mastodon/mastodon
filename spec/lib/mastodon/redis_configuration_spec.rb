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
  end

  describe '#sidekiq' do
    subject { redis_environment.sidekiq }

    include_examples 'secondary configuration', 'SIDEKIQ'
    include_examples 'setting a different driver'
    include_examples 'setting a namespace'
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
  end
end
