require 'spec_helper'

# TODO: add more specs here later
describe Chewy::Type::Import::Routine do
  before { Chewy.massacre }
  before do
    stub_index(:cities) do
      define_type :city do
        field :name
        field :object, type: 'object'
      end
    end
    CitiesIndex.create!
  end

  let(:index) { [double(id: 1, name: 'Name', object: {}), double(id: 2, name: 'Name', object: {})] }
  let(:delete) { [double(id: 3, name: 'Name')] }

  describe '#options' do
    specify do
      expect(described_class.new(CitiesIndex::City).options).to eq(
        journal: nil,
        refresh: true,
        update_failover: true,
        update_fields: [],
        batch_size: 1000
      )
    end

    specify do
      expect(described_class.new(
        CitiesIndex::City, batch_size: 100, bulk_size: 1.megabyte, refresh: false
      ).options).to eq(
        journal: nil,
        refresh: false,
        update_failover: true,
        update_fields: [],
        bulk_size: 1_048_576,
        batch_size: 100
      )
    end

    context do
      before { allow(Chewy).to receive_messages(configuration: Chewy.configuration.merge(journal: true)) }
      specify do
        expect(described_class.new(CitiesIndex::City).options).to eq(
          journal: true,
          refresh: true,
          update_failover: true,
          update_fields: [],
          batch_size: 1000
        )
      end
    end

    specify do
      expect(CitiesIndex.client).to receive(:bulk).with(hash_including(refresh: true))
      described_class.new(CitiesIndex::City).process(index: index)
    end

    specify do
      expect(CitiesIndex.client).to receive(:bulk).with(hash_including(refresh: false))
      described_class.new(CitiesIndex::City, refresh: false).process(index: index)
    end
  end

  describe '#parallel_options' do
    specify { expect(described_class.new(CitiesIndex::City).parallel_options).to be_nil }
    specify { expect(described_class.new(CitiesIndex::City, parallel: true).parallel_options).to eq({}) }
    specify { expect(described_class.new(CitiesIndex::City, parallel: 3).parallel_options).to eq(in_processes: 3) }
    specify { expect(described_class.new(CitiesIndex::City, parallel: {in_threads: 2}).parallel_options).to eq(in_threads: 2) }
  end

  describe '#stats' do
    subject { described_class.new(CitiesIndex::City) }

    specify { expect(subject.stats).to eq({}) }
    specify do
      expect { subject.process(index: index) }
        .to change { subject.stats }.to(index: 2)
    end
    specify do
      expect { subject.process(index: index, delete: delete) }
        .to change { subject.stats }.to(index: 2, delete: 1)
    end
    specify do
      expect do
        subject.process(index: index, delete: delete)
        subject.process(index: index, delete: delete)
      end.to change { subject.stats }.to(index: 4, delete: 2)
    end
  end

  describe '#errors' do
    subject { described_class.new(CitiesIndex::City) }
    let(:index) { [double(id: 1, name: 'Name', object: ''), double(id: 2, name: 'Name', object: {})] }

    specify { expect(subject.errors).to eq([]) }
    specify do
      expect { subject.process(index: index) }
        .to change { subject.errors }.to(have(1).item)
    end
    specify do
      expect do
        subject.process(index: index)
        subject.process(index: index)
      end.to change { subject.errors }.to(have(2).items)
    end
  end
end
