# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TagFilter do
  describe 'with invalid params' do
    it 'raises with key error' do
      filter = described_class.new(wrong: true)

      expect { filter.results }.to raise_error(/wrong/)
    end

    it 'raises with status scope error' do
      filter = described_class.new(status: 'unknown')

      expect { filter.results }.to raise_error(/Unknown status: unknown/)
    end

    it 'raises with order value error' do
      filter = described_class.new(order: 'unknown')

      expect { filter.results }.to raise_error(/Unknown order: unknown/)
    end
  end

  describe '#results' do
    let(:listable_tag) { Fabricate(:tag, name: 'test1', listable: true) }
    let(:not_listable_tag) { Fabricate(:tag, name: 'test2', listable: false) }

    it 'returns tags filtered by name' do
      filter = described_class.new(name: 'test')

      expect(filter.results).to eq([listable_tag, not_listable_tag])
    end
  end
end
