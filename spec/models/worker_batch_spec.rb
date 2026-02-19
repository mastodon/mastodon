# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkerBatch do
  subject { described_class.new }

  let(:async_refresh_key) { 'test_refresh' }
  let(:async_refresh) { nil }

  describe '#id' do
    it 'returns a string' do
      expect(subject.id).to be_a String
    end
  end

  describe '#connect' do
    before do
      subject.connect(async_refresh_key, threshold: 0.75)
    end

    it 'persists the async refresh key' do
      expect(subject.info['async_refresh_key']).to eq async_refresh_key
    end

    it 'persists the threshold' do
      expect(subject.info['threshold']).to eq '0.75'
    end
  end

  describe '#add_jobs' do
    before do
      subject.connect(async_refresh_key, threshold: 0.5) if async_refresh.present?
      subject.add_jobs([])
    end

    context 'when called with empty array' do
      it 'does not persist the number of pending jobs' do
        expect(subject.info).to be_empty
      end

      it 'does not persist the job IDs' do
        expect(subject.jobs).to eq []
      end
    end

    context 'when called with an array of job IDs' do
      before do
        subject.add_jobs(%w(foo bar))
      end

      it 'persists the number of pending jobs' do
        expect(subject.info['pending']).to eq '2'
      end

      it 'persists the job IDs' do
        expect(subject.jobs).to contain_exactly('foo', 'bar')
      end
    end
  end

  describe '#remove_job' do
    before do
      subject.connect(async_refresh_key, threshold: 0.5) if async_refresh.present?
      subject.add_jobs(%w(foo bar baz))
      subject.remove_job('foo', increment: true)
    end

    it 'removes the job from pending jobs' do
      expect(subject.jobs).to contain_exactly('bar', 'baz')
    end

    it 'decrements the number of pending jobs' do
      expect(subject.info['pending']).to eq '2'
    end

    context 'when async refresh is connected' do
      let(:async_refresh) { AsyncRefresh.new(async_refresh_key) }

      it 'increments async refresh progress' do
        expect(async_refresh.reload.result_count).to eq 1
      end

      it 'marks the async refresh as finished when the threshold is reached' do
        subject.remove_job('bar')
        expect(async_refresh.reload.finished?).to be true
      end
    end
  end

  describe '#info' do
    it 'returns a hash' do
      expect(subject.info).to be_a Hash
    end
  end
end
