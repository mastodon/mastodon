# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InteractionPolicy do
  subject { described_class.new(bitmap) }

  let(:bitmap) { (0b0101 << 16) | 0b0010 }

  describe described_class::SubPolicy do
    subject { InteractionPolicy.new(bitmap) }

    describe '#as_keys' do
      it 'returns the expected values' do
        expect(subject.automatic.as_keys).to eq ['unsupported_policy', 'followers']
        expect(subject.manual.as_keys).to eq ['public']
      end
    end

    describe '#public?' do
      it 'returns the expected values' do
        expect(subject.automatic.public?).to be false
        expect(subject.manual.public?).to be true
      end
    end

    describe '#unsupported_policy?' do
      it 'returns the expected values' do
        expect(subject.automatic.unsupported_policy?).to be true
        expect(subject.manual.unsupported_policy?).to be false
      end
    end

    describe '#followers?' do
      it 'returns the expected values' do
        expect(subject.automatic.followers?).to be true
        expect(subject.manual.followers?).to be false
      end
    end
  end
end
