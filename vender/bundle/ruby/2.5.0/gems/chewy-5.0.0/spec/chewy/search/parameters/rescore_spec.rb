require 'spec_helper'

describe Chewy::Search::Parameters::Rescore do
  subject { described_class.new([{foo: 42}, {bar: 43}]) }

  describe '#initialize' do
    specify { expect(described_class.new.value).to eq([]) }
    specify { expect(described_class.new(nil).value).to eq([]) }
    specify { expect(described_class.new(foo: 42).value).to eq([{foo: 42}]) }
    specify { expect(described_class.new([{foo: 42}, nil]).value).to eq([{foo: 42}]) }
    specify { expect(subject.value).to eq([{foo: 42}, {bar: 43}]) }
  end

  describe '#replace!' do
    specify do
      expect { subject.replace!(nil) }
        .to change { subject.value }
        .from([{foo: 42}, {bar: 43}]).to([])
    end

    specify do
      expect { subject.replace!(baz: 44) }
        .to change { subject.value }
        .from([{foo: 42}, {bar: 43}])
        .to([{baz: 44}])
    end
  end

  describe '#update!' do
    specify do
      expect { subject.update!(nil) }
        .not_to change { subject.value }
    end

    specify do
      expect { subject.update!(baz: 44) }
        .to change { subject.value }
        .from([{foo: 42}, {bar: 43}])
        .to([{foo: 42}, {bar: 43}, {baz: 44}])
    end
  end

  describe '#merge!' do
    specify do
      expect { subject.merge!(described_class.new) }
        .not_to change { subject.value }
    end

    specify do
      expect { subject.merge!(described_class.new(baz: 44)) }
        .to change { subject.value }
        .from([{foo: 42}, {bar: 43}])
        .to([{foo: 42}, {bar: 43}, {baz: 44}])
    end
  end

  describe '#render' do
    specify { expect(described_class.new.render).to be_nil }
    specify { expect(described_class.new(foo: 42).render).to eq(rescore: [{foo: 42}]) }
    specify { expect(subject.render).to eq(rescore: [{foo: 42}, {bar: 43}]) }
  end
end
