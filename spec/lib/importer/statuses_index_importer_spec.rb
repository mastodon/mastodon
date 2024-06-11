# frozen_string_literal: true

require 'rails_helper'

describe Importer::StatusesIndexImporter do
  describe 'import!' do
    let(:pool) { Concurrent::FixedThreadPool.new(5) }
    let(:importer) { described_class.new(batch_size: 123, executor: pool) }

    before { Fabricate(:status) }

    it 'indexes relevant statuses' do
      expect { importer.import! }.to update_index(StatusesIndex)
    end
  end
end
