# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::PublicStatusesIndexImporter do
  describe 'import!' do
    let(:pool) { Concurrent::FixedThreadPool.new(5) }
    let(:importer) { described_class.new(batch_size: 123, executor: pool) }

    before { Fabricate(:status, account: Fabricate(:account, indexable: true)) }

    it 'indexes relevant statuses' do
      expect { importer.import! }.to update_index(PublicStatusesIndex)
    end
  end
end
