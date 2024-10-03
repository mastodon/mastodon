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
end
