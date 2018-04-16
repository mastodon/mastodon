require 'spec_helper'

describe Chewy::Search::Parameters::Order do
  subject { described_class.new(%i[foo bar]) }

  describe '#initialize' do
    specify { expect(described_class.new.value).to eq({}) }
    specify { expect(described_class.new(nil).value).to eq({}) }
    specify { expect(described_class.new('').value).to eq({}) }
    specify { expect(described_class.new(42).value).to eq('42' => nil) }
    specify { expect(described_class.new([42, 43]).value).to eq('42' => nil, '43' => nil) }
    specify { expect(described_class.new(a: 1).value).to eq('a' => 1) }
    specify { expect(described_class.new(['', 43, a: 1]).value).to eq('a' => 1, '43' => nil) }
  end

  describe '#replace!' do
    specify do
      expect { subject.replace!(foo: {}) }
        .to change { subject.value }
        .from('foo' => nil, 'bar' => nil).to('foo' => {})
    end

    specify do
      expect { subject.replace!(nil) }
        .to change { subject.value }
        .from('foo' => nil, 'bar' => nil).to({})
    end
  end

  describe '#update!' do
    specify do
      expect { subject.update!(foo: {}) }
        .to change { subject.value }
        .from('foo' => nil, 'bar' => nil).to('foo' => {}, 'bar' => nil)
    end

    specify { expect { subject.update!(nil) }.not_to change { subject.value } }
  end

  describe '#merge!' do
    specify do
      expect { subject.merge!(described_class.new(foo: {})) }
        .to change { subject.value }
        .from('foo' => nil, 'bar' => nil).to('foo' => {}, 'bar' => nil)
    end

    specify { expect { subject.merge!(described_class.new) }.not_to change { subject.value } }
  end

  describe '#render' do
    specify { expect(described_class.new.render).to be_nil }
    specify { expect(described_class.new(:foo).render).to eq(sort: ['foo']) }
    specify { expect(described_class.new([:foo, {bar: 42}, :baz]).render).to eq(sort: ['foo', {'bar' => 42}, 'baz']) }
  end

  describe '#==' do
    specify { expect(described_class.new).to eq(described_class.new) }
    specify { expect(described_class.new(:foo)).to eq(described_class.new(:foo)) }
    specify { expect(described_class.new(:foo)).not_to eq(described_class.new(:bar)) }
    specify { expect(described_class.new(%i[foo bar])).to eq(described_class.new(%i[foo bar])) }
    specify { expect(described_class.new(%i[foo bar])).not_to eq(described_class.new(%i[bar foo])) }
    specify { expect(described_class.new(foo: {a: 42})).to eq(described_class.new(foo: {a: 42})) }
    specify { expect(described_class.new(foo: {a: 42})).not_to eq(described_class.new(foo: {b: 42})) }
  end
end
