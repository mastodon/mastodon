# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BackgroundJob do
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
        id = Rails.application.message_verifier('background_jobs').generate(redis_key)
        background_job = described_class.find(id)

        expect(background_job).to be_a described_class
      end
    end

    context 'when no matching job in redis exists' do
      it 'returns `nil`' do
        id = Rails.application.message_verifier('background_jobs').generate('non_existent')
        expect(described_class.find(id)).to be_nil
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

  describe '#result_count' do
    before do
      redis.hset(redis_key, job_hash)
    end

    it 'returns the result count from redis' do
      expect(subject.result_count).to eq 23
    end
  end
end
