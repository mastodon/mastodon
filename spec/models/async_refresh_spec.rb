# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AsyncRefresh do
  subject { described_class.new(redis_key) }

  let(:redis_key) { 'testjob:key' }
  let(:status) { 'running' }
  let(:job_hash) { { 'status' => status, 'result_count' => 23 } }

  describe '::find' do
    context 'when a matching job in redis exists' do
      before do
        redis.hset(redis_key, job_hash)
      end

      it 'returns a new instance' do
        id = Rails.application.message_verifier('async_refreshes').generate(redis_key)
        async_refresh = described_class.find(id)

        expect(async_refresh).to be_a described_class
      end
    end

    context 'when no matching job in redis exists' do
      it 'returns `nil`' do
        id = Rails.application.message_verifier('async_refreshes').generate('non_existent')
        expect(described_class.find(id)).to be_nil
      end
    end
  end

  describe '::create' do
    it 'inserts the given key into redis' do
      described_class.create(redis_key)

      expect(redis.exists?(redis_key)).to be true
    end

    it 'sets the status to `running`' do
      async_refresh = described_class.create(redis_key)

      expect(async_refresh.status).to eq 'running'
    end

    context 'with `count_results`' do
      it 'set `result_count` to 0' do
        async_refresh = described_class.create(redis_key, count_results: true)

        expect(async_refresh.result_count).to eq 0
      end
    end

    context 'without `count_results`' do
      it 'does not set `result_count`' do
        async_refresh = described_class.create(redis_key)

        expect(async_refresh.result_count).to be_nil
      end
    end
  end

  describe '#id' do
    before do
      redis.hset(redis_key, job_hash)
    end

    it "returns a signed version of the job's redis key" do
      id = subject.id
      key_name = Base64.decode64(id.split('-').first)

      expect(key_name).to include redis_key
    end
  end

  describe '#status' do
    before do
      redis.hset(redis_key, job_hash)
    end

    context 'when the job is running' do
      it "returns 'running'" do
        expect(subject.status).to eq 'running'
      end
    end

    context 'when the job is finished' do
      let(:status) { 'finished' }

      it "returns 'finished'" do
        expect(subject.status).to eq 'finished'
      end
    end
  end

  describe '#running?' do
    before do
      redis.hset(redis_key, job_hash)
    end

    context 'when the job is running' do
      it 'returns `true`' do
        expect(subject.running?).to be true
      end
    end

    context 'when the job is finished' do
      let(:status) { 'finished' }

      it 'returns `false`' do
        expect(subject.running?).to be false
      end
    end
  end

  describe '#finished?' do
    before do
      redis.hset(redis_key, job_hash)
    end

    context 'when the job is running' do
      it 'returns `false`' do
        expect(subject.finished?).to be false
      end
    end

    context 'when the job is finished' do
      let(:status) { 'finished' }

      it 'returns `true`' do
        expect(subject.finished?).to be true
      end
    end
  end

  describe '#finish!' do
    before do
      redis.hset(redis_key, job_hash)
    end

    it 'sets the status to `finished`' do
      subject.finish!

      expect(subject).to be_finished
    end
  end

  describe '#result_count' do
    before do
      redis.hset(redis_key, job_hash)
    end

    it 'returns the result count from redis' do
      expect(subject.result_count).to eq 23
    end
  end

  describe '#reload' do
    before do
      redis.hset(redis_key, job_hash)
    end

    it 'reloads the current data from redis and returns itself' do
      expect(subject).to be_running
      redis.hset(redis_key, { 'status' => 'finished' })
      expect(subject).to be_running

      expect(subject.reload).to eq subject

      expect(subject).to be_finished
    end
  end
end
