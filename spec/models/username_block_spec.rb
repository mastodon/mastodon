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

  describe '#comparison' do
    subject { username_block.comparison }

    let(:username_block) { Fabricate.build(:username_block, exact: exact) }

    context 'when exact is true' do
      let(:exact) { true }

      it { is_expected.to eq('equals') }
    end

    context 'when exact is false' do
      let(:exact) { false }

      it { is_expected.to eq('contains') }
    end
  end

  describe '#comparison=' do
    subject do
      username_block.comparison = comparison
      username_block.exact
    end

    let(:username_block) { Fabricate.build(:username_block) }

    context 'when comparison is equals' do
      let(:comparison) { 'equals' }

      it { is_expected.to be(true) }
    end

    context 'when comparison is contains' do
      let(:comparison) { 'contains' }

      it { is_expected.to be(false) }
    end
  end

  describe '#to_log_human_identifier' do
    subject { username_block.to_log_human_identifier }

    let(:username_block) { Fabricate.build(:username_block, username: 'harry') }

    it { is_expected.to eq('harry') }
  end
end
