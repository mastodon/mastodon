require 'spec_helper'

describe Chewy::Search::Parameters::MinScore do
  subject { described_class.new(0.5) }

  describe '#initialize' do
    specify { expect(described_class.new.value).to be_nil }
    specify { expect(described_class.new('1.4').value).to eq(1.4) }
    specify { expect(described_class.new(2).value).to eq(2.0) }
    specify { expect(described_class.new(nil).value).to be_nil }
  end

  describe '#replace!' do
    specify { expect { subject.replace!(1.4) }.to change { subject.value }.from(0.5).to(1.4) }
    specify { expect { subject.replace!(nil) }.to change { subject.value }.from(0.5).to(nil) }
  end

  describe '#update!' do
    specify { expect { subject.update!('1.4') }.to change { subject.value }.from(0.5).to(1.4) }
    specify { expect { subject.update!(nil) }.not_to change { subject.value }.from(0.5) }
  end

  describe '#merge!' do
    specify { expect { subject.merge!(described_class.new('2')) }.to change { subject.value }.from(0.5).to(2.0) }
    specify { expect { subject.merge!(described_class.new) }.not_to change { subject.value }.from(0.5) }
  end

  describe '#render' do
    specify { expect(described_class.new.render).to be_nil }
    specify { expect(described_class.new('1.4').render).to eq(min_score: 1.4) }
  end
end
