# frozen_string_literal: true

require 'rails_helper'

describe Admin::TagFilter do
  describe '#results' do
    let(:listable_tag) { Fabricate(:tag, name: 'test1', listable: true) }
    let(:not_listable_tag) { Fabricate(:tag, name: 'test2', listable: false) }

    it 'returns filtered tags' do
      filter = described_class.new(name: 'test')

      expect(filter.results).to eq([listable_tag, not_listable_tag])
    end
  end
end
