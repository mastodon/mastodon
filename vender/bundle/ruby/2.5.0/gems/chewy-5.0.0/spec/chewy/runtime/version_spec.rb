require 'spec_helper'

describe Chewy::Runtime::Version do
  describe '#major' do
    specify { expect(described_class.new('1.2.3').major).to eq(1) }
    specify { expect(described_class.new('1.2').major).to eq(1) }
    specify { expect(described_class.new(1.2).major).to eq(1) }
    specify { expect(described_class.new('1').major).to eq(1) }
    specify { expect(described_class.new('').major).to eq(0) }
  end

  describe '#minor' do
    specify { expect(described_class.new('1.2.3').minor).to eq(2) }
    specify { expect(described_class.new('1.2').minor).to eq(2) }
    specify { expect(described_class.new(1.2).minor).to eq(2) }
    specify { expect(described_class.new('1').minor).to eq(0) }
  end

  describe '#patch' do
    specify { expect(described_class.new('1.2.3').patch).to eq(3) }
    specify { expect(described_class.new('1.2.3.pre1').patch).to eq(3) }
    specify { expect(described_class.new('1.2').patch).to eq(0) }
    specify { expect(described_class.new(1.2).patch).to eq(0) }
  end

  describe '#to_s' do
    specify { expect(described_class.new('1.2.3').to_s).to eq('1.2.3') }
    specify { expect(described_class.new('1.2.3.pre1').to_s).to eq('1.2.3') }
    specify { expect(described_class.new('1.2').to_s).to eq('1.2.0') }
    specify { expect(described_class.new(1.2).to_s).to eq('1.2.0') }
    specify { expect(described_class.new('1').to_s).to eq('1.0.0') }
    specify { expect(described_class.new('').to_s).to eq('0.0.0') }
  end

  describe '#<=>' do
    specify { expect(described_class.new('1.2.3')).to eq('1.2.3') }
    specify { expect(described_class.new('1.2.3')).to be < '1.2.4' }
    specify { expect(described_class.new('1.2.3')).to be < '1.2.10' }
    specify { expect(described_class.new('1.10.2')).to eq('1.10.2') }
    specify { expect(described_class.new('1.10.2')).to be > '1.7.2' }
    specify { expect(described_class.new('2.10.2')).to be > '1.7.2' }
    specify { expect(described_class.new('1.10.2')).to be < '2.7.2' }
    specify { expect(described_class.new('1.10.2')).to be < described_class.new('2.7.2') }
    specify { expect(described_class.new('1.10.2')).to be < 2.7 }
    specify { expect(described_class.new('1.10.2')).to be < 1.11 }
    specify { expect(described_class.new('1.2.0')).to eq('1.2') }
  end
end
