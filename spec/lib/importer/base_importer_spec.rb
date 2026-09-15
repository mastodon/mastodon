# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::BaseImporter do
  let(:pool) { Concurrent::FixedThreadPool.new(5) }
  let(:importer) { described_class.new(batch_size: 123, executor: pool) }

  describe 'import!' do
    it 'raises an error' do
      expect { importer.import! }.to raise_error(NotImplementedError)
    end
  end

  describe 'clean_up!' do
    let(:tracked_index) { spy }
    let(:index) { spy }

    before do
      allow(importer).to receive(:index).and_return(index)
      allow(index).to receive(:track_total_hits).with(true).and_return(tracked_index)
      allow(tracked_index).to receive(:scroll_batches)
    end

    it 'scrolls every document with the configured batch size' do
      importer.clean_up!

      expect(index).to have_received(:track_total_hits).with(true)
      expect(tracked_index).to have_received(:scroll_batches).with(batch_size: 123)
    end
  end
end
