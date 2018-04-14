require 'spec_helper'

describe Chewy::Search::Parameters do
  subject { described_class.new }

  describe '.storages' do
    specify { expect(described_class.storages[:limit]).to eq(Chewy::Search::Parameters::Limit) }
  end

  describe '#initialize' do
    let(:limit) { described_class.storages[:limit].new(3) }
    subject { described_class.new(limit: limit, order: :foo) }

    specify { expect(subject.storages[:limit]).to equal(limit) }
    specify { expect(subject.storages[:limit].value).to eq(3) }
    specify { expect(subject.storages[:order].value).to eq('foo' => nil) }

    specify { expect { described_class.new(offset: limit) }.to raise_error(TypeError) }
  end

  describe '#storages' do
    specify { expect(subject.storages).to eq({}) }
    specify { expect(subject.storages[:limit]).to be_a(Chewy::Search::Parameters::Limit) }
  end

  describe '#==' do
    specify { expect(described_class.new(limit: 10)).to eq(described_class.new(limit: 10)) }
    specify { expect(described_class.new(limit: 10)).to eq(described_class.new(limit: 10, offset: nil)) }
    specify { expect(described_class.new(limit: 10, offset: 20)).to eq(described_class.new(limit: 10, offset: 20)) }
    specify { expect(described_class.new(limit: 10)).not_to eq(described_class.new(limit: 20)) }
    specify { expect(described_class.new(limit: 10)).not_to eq(described_class.new(limit: 10, offset: 20)) }
  end

  describe '#modify!' do
    it 'updates the storage value' do
      expect { subject.modify!(:limit) { replace!(42) } }
        .to change { subject[:limit].value }
        .from(nil).to(42)
    end

    it 'replaces the storage' do
      expect { subject.modify!(:limit) { replace!(42) } }
        .to change { subject[:limit].object_id }
    end

    it 'doesn\'t change the old object' do
      subject.modify!(:limit) { replace!(42) }
      old_limit = subject[:limit]
      subject.modify!(:limit) { replace!(43) }
      expect(old_limit.value).to eq(42)
    end
  end

  describe '#only!' do
    subject { described_class.new(limit: 10, offset: 20, order: :foo) }

    specify { expect { subject.only!([:limit]) }.to change { subject.clone }.to(described_class.new(limit: 10)) }
    specify { expect { subject.only!(%i[offset order]) }.to change { subject.clone }.to(described_class.new(offset: 20, order: :foo)) }
    specify { expect { subject.only!(%i[limit something]) }.to raise_error NameError }
    specify { expect { subject.only!([]) }.to raise_error ArgumentError }
  end

  describe '#except!' do
    subject { described_class.new(limit: 10, offset: 20, order: :foo) }

    specify { expect { subject.except!([:limit]) }.to change { subject.clone }.to(described_class.new(offset: 20, order: :foo)) }
    specify { expect { subject.except!(%i[offset order]) }.to change { subject.clone }.to(described_class.new(limit: 10)) }
    specify { expect { subject.except!(%i[limit something]) }.to raise_error NameError }
    specify { expect { subject.except!([]) }.to raise_error ArgumentError }
  end

  describe '#merge!' do
    let(:first) { described_class.new(offset: 10, order: 'foo') }
    let(:second) { described_class.new(limit: 20, offset: 20, order: 'bar') }

    specify do
      expect { first.merge!(second) }.to change { first.clone }
        .to(described_class.new(limit: 20, offset: 20, order: %w[foo bar]))
    end
    specify { expect { first.merge!(second) }.not_to change { second.clone } }

    specify do
      expect { second.merge!(first) }.to change { second.clone }
        .to(described_class.new(limit: 20, offset: 10, order: %w[bar foo]))
    end
    specify { expect { second.merge!(first) }.not_to change { first.clone } }

    context 'spawns new storages for the merge' do
      let(:names) { %i[limit offset order] }
      def storage_object_ids(params)
        params.storages.values_at(*names).map(&:object_id)
      end

      specify { expect(storage_object_ids(first) | storage_object_ids(subject)).to have(6).items }
      specify { expect(storage_object_ids(second) | storage_object_ids(subject)).to have(6).items }
    end
  end

  describe '#render' do
    subject { described_class.new(offset: 10, order: 'foo') }

    specify { expect(subject.render).to eq(body: {from: 10, sort: ['foo']}) }
    specify { expect(described_class.new.render).to eq({}) }

    context do
      subject { described_class.new(query: {foo: 'bar'}, filter: {moo: 'baz'}) }
      specify { expect(subject.render).to eq(body: {query: {bool: {must: {foo: 'bar'}, filter: {moo: 'baz'}}}}) }
    end

    context do
      subject { described_class.new(query: {should: {foo: 'bar'}}, filter: {moo: 'baz'}) }
      specify { expect(subject.render).to eq(body: {query: {bool: {should: {foo: 'bar'}, filter: {moo: 'baz'}}}}) }
    end

    context do
      subject { described_class.new(query: {must_not: {foo: 'bar'}}, filter: {moo: 'baz'}) }
      specify { expect(subject.render).to eq(body: {query: {bool: {must_not: {foo: 'bar'}, filter: {moo: 'baz'}}}}) }
    end

    context do
      subject { described_class.new(filter: {moo: 'baz'}) }
      specify { expect(subject.render).to eq(body: {query: {bool: {filter: {moo: 'baz'}}}}) }
    end

    context do
      subject { described_class.new(filter: {moo: 'baz'}, none: true) }
      specify { expect(subject.render).to eq(body: {query: {bool: {filter: {bool: {must_not: {match_all: {}}}}}}}) }
    end
  end
end
