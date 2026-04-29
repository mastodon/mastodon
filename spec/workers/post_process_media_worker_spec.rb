# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostProcessMediaWorker, :attachment_processing do
  let(:worker) { described_class.new }

  describe '#perform' do
    let(:media_attachment) { Fabricate(:media_attachment) }

    it 'reprocesses and updates the media attachment' do
      worker.perform(media_attachment.id)

      expect(media_attachment.processing).to eq('complete')
    end

    it 'returns true for non-existent record' do
      result = worker.perform(123_123_123)

      expect(result).to be(true)
    end

    context 'when media is already processed' do
      before do
        media_attachment.update!(processing: :complete)
      end

      it 'skips reprocessing and returns true' do
        expect(media_attachment.file).not_to receive(:reprocess!)

        result = worker.perform(media_attachment.id)

        expect(result).to be(true)
        expect(media_attachment.reload.processing).to eq('complete')
      end
    end

    context 'when media is in progress' do
      before do
        media_attachment.update!(processing: :in_progress, updated_at: 5.minutes.ago)
      end

      it 'skips reprocessing if not stuck' do
        expect(media_attachment.file).not_to receive(:reprocess!)

        result = worker.perform(media_attachment.id)

        expect(result).to be(true)
      end

      context 'when processing is stuck' do
        before do
          media_attachment.update!(updated_at: 20.minutes.ago)
        end

        it 'reprocesses the media' do
          worker.perform(media_attachment.id)

          expect(media_attachment.reload.processing).to eq('complete')
        end
      end
    end

    context 'when media processing failed' do
      before do
        media_attachment.update!(processing: :failed)
      end

      it 'retries processing' do
        worker.perform(media_attachment.id)

        expect(media_attachment.reload.processing).to eq('complete')
      end
    end

    context 'with duplicate execution (simulating Redis transient error)' do
      it 'does not cause duplicate processing' do
        allow(media_attachment.file).to receive(:reprocess!).and_wrap_original do |original, *args|
          original.call(*args)
        end

        expect(media_attachment.file).to receive(:reprocess!).once

        thread1 = Thread.new { worker.perform(media_attachment.id) }
        thread2 = Thread.new { worker.perform(media_attachment.id) }

        thread1.join
        thread2.join

        expect(media_attachment.reload.processing).to eq('complete')
      end
    end

    context 'when sidekiq retries are exhausted' do
      it 'sets state to failed' do
        described_class.within_sidekiq_retries_exhausted_block({ 'args' => [media_attachment.id] }) do
          worker.perform(media_attachment.id)
        end

        expect(media_attachment.reload.processing).to eq('failed')
      end

      it 'returns true for non-existent record' do
        described_class.within_sidekiq_retries_exhausted_block({ 'args' => [123_123_123] }) do
          expect(worker.perform(123_123_123)).to be(true)
        end
      end
    end
  end

  describe '#processing_stuck?' do
    let(:media_attachment) { Fabricate(:media_attachment) }

    it 'returns true when updated_at is older than MAX_PROCESSING_TIME' do
      media_attachment.update!(updated_at: 20.minutes.ago)

      expect(worker.send(:processing_stuck?, media_attachment)).to be(true)
    end

    it 'returns false when updated_at is within MAX_PROCESSING_TIME' do
      media_attachment.update!(updated_at: 5.minutes.ago)

      expect(worker.send(:processing_stuck?, media_attachment)).to be(false)
    end
  end
end
