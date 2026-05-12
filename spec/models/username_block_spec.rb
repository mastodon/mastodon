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

  describe 'instance methods' do
    subject(:username_block) { described_class.new }

    describe '#comparison' do
      subject(:username_block) { described_class.new(exact: exact) }

      context 'when exact is true' do
        let(:exact) { true }

        it 'returns equals' do
          expect(username_block.comparison).to eq('equals')
        end
      end

      context 'when exact is false' do
        let(:exact) { false }

        it 'returns contains' do
          expect(username_block.comparison).to eq('contains')
        end
      end
    end

    describe '#comparison=' do
      it 'sets exact to true when equals is passed' do
        username_block.comparison = 'equals'
        expect(username_block.exact).to be(true)
      end

      it 'sets exact to false when contains is passed' do
        username_block.comparison = 'contains'
        expect(username_block.exact).to be(false)
      end
    end

    describe '#to_log_human_identifier' do
      it 'returns the username' do
        username_block.username = 'harry'

        expect(username_block.to_log_human_identifier).to eq('harry')
      end
    end
  end
end
