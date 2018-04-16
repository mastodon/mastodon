require 'spec_helper'

describe Chewy::Search::Parameters::IndicesBoost do
  subject { described_class.new(index: 1.2) }

  describe '#initialize' do
    specify { expect(described_class.new.value).to eq({}) }
    specify { expect(described_class.new(nil).value).to eq({}) }
    specify { expect(subject.value).to eq('index' => 1.2) }
    specify { expect(described_class.new(index: '1.2', other: 2).value).to eq('index' => 1.2, 'other' => 2.0) }
  end

  describe '#replace!' do
    specify do
      expect { subject.replace!(nil) }
        .to change { subject.value }.from('index' => 1.2).to({})
    end

    specify do
      expect { subject.replace!(other: 3.1) }
        .to change { subject.value }
        .from('index' => 1.2).to('other' => 3.1)
    end
  end

  describe '#update!' do
    specify do
      expect { subject.update!(nil) }
        .not_to change { subject.value }
    end

    specify do
      expect { subject.update!(other: 3.1) }
        .to change { subject.value }
        .from('index' => 1.2).to('index' => 1.2, 'other' => 3.1)
    end

    context do
      before { subject.update!(other: 3.1) }

      specify do
        expect { subject.update!(index: 1.5) }
          .to change { subject.value }
          .from('index' => 1.2, 'other' => 3.1).to('index' => 1.5, 'other' => 3.1)
      end

      specify do
        expect { subject.update!(index: 1.5) }
          .to change { subject.value.keys }
          .from(%w[index other]).to(%w[other index])
      end
    end
  end

  describe '#merge!' do
    specify do
      expect { subject.merge!(described_class.new) }
        .not_to change { subject.value }
    end

    specify do
      expect { subject.merge!(described_class.new(other: 3.1)) }
        .to change { subject.value }
        .from('index' => 1.2)
        .to('index' => 1.2, 'other' => 3.1)
    end
  end

  describe '#render' do
    specify { expect(described_class.new.render).to be_nil }
    specify { expect(described_class.new(index: 1.2).render).to eq(indices_boost: [{'index' => 1.2}]) }
    specify { expect(described_class.new(index: 1.2, other: 1.3).render).to eq(indices_boost: [{'index' => 1.2}, {'other' => 1.3}]) }
    specify { expect(described_class.new(index: 1.2, other: 1.3).tap { |i| i.update!(index: '1.5') }.render).to eq(indices_boost: [{'other' => 1.3}, {'index' => 1.5}]) }
  end

  describe '#==' do
    specify { expect(described_class.new).to eq(described_class.new) }
    specify { expect(described_class.new(index: 1.2)).to eq(described_class.new(index: 1.2)) }
    specify { expect(described_class.new(index: 1.2)).not_to eq(described_class.new(other: 1.3)) }
    specify { expect(described_class.new(index: 1.2, other: 1.3)).to eq(described_class.new(index: 1.2, other: 1.3)) }
    specify { expect(described_class.new(index: 1.2, other: 1.3)).not_to eq(described_class.new(other: 1.3, index: 1.2)) }
  end
end
