# frozen_string_literal: true

require 'rails_helper'

describe Importer::AccountsIndexImporter do
  describe 'import!' do
    let(:pool) { Concurrent::FixedThreadPool.new(5) }
    let(:importer) { described_class.new(batch_size: 123, executor: pool) }

    before { Fabricate(:account) }

    it 'indexes relevant accounts' do
      expect { importer.import! }.to update_index(AccountsIndex)
    end
  end
end
