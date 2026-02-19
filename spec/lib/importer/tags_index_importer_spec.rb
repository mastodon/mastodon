# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importer::TagsIndexImporter do
  describe 'import!' do
    let(:pool) { Concurrent::FixedThreadPool.new(5) }
    let(:importer) { described_class.new(batch_size: 123, executor: pool) }

    before { Fabricate(:tag) }

    it 'indexes relevant tags' do
      expect { importer.import! }.to update_index(TagsIndex)
    end
  end
end
