# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::BaseImporter do
  describe 'import!' do
    let(:pool) { Concurrent::FixedThreadPool.new(5) }
    let(:importer) { described_class.new(batch_size: 123, executor: pool) }

    it 'raises an error' do
      expect { importer.import! }.to raise_error(NotImplementedError)
    end
  end
end
