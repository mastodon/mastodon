# frozen_string_literal: true

require 'rails_helper'

describe JsonLdHelper do
  describe '#equals_or_includes?' do
    it 'returns true when value equals' do
      expect(described_class.equals_or_includes?('foo', 'foo')).to be true
    end

    it 'returns false when value does not equal' do
      expect(described_class.equals_or_includes?('foo', 'bar')).to be false
    end

    it 'returns true when value is included' do
      expect(described_class.equals_or_includes?(%w(foo baz), 'foo')).to be true
    end

    it 'returns false when value is not included' do
      expect(described_class.equals_or_includes?(%w(foo baz), 'bar')).to be false
    end
  end
end
