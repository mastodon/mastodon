# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsernameBlock do
  describe '.matches?' do
    context 'when there is an exact block' do
      before do
        Fabricate(:username_block, username: 'carriage', exact: true)
      end

      it 'returns true on exact match' do
        expect(described_class.matches?('carriage')).to be true
      end

      it 'returns true on case insensitive match' do
        expect(described_class.matches?('CaRRiagE')).to be true
      end

      it 'returns true on homoglyph match' do
        expect(described_class.matches?('c4rr14g3')).to be true
      end

      it 'returns false on partial match' do
        expect(described_class.matches?('foo_carriage')).to be false
      end

      it 'returns false on no match' do
        expect(described_class.matches?('foo')).to be false
      end
    end

    context 'when there is a partial block' do
      before do
        Fabricate(:username_block, username: 'carriage', exact: false)
      end

      it 'returns true on exact match' do
        expect(described_class.matches?('carriage')).to be true
      end

      it 'returns true on case insensitive match' do
        expect(described_class.matches?('CaRRiagE')).to be true
      end

      it 'returns true on homoglyph match' do
        expect(described_class.matches?('c4rr14g3')).to be true
      end

      it 'returns true on suffix match' do
        expect(described_class.matches?('foo_carriage')).to be true
      end

      it 'returns true on prefix match' do
        expect(described_class.matches?('carriage_foo')).to be true
      end

      it 'returns false on no match' do
        expect(described_class.matches?('foo')).to be false
      end
    end
  end
end
