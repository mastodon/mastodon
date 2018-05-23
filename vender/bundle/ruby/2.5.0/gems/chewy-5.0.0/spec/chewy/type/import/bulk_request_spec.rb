require 'spec_helper'

describe Chewy::Type::Import::BulkRequest do
  before { Chewy.massacre }

  subject { described_class.new(type, suffix: suffix, bulk_size: bulk_size, **bulk_options) }
  let(:suffix) {}
  let(:bulk_size) {}
  let(:bulk_options) { {} }
  let(:type) { PlacesIndex::City }

  describe '#initialize' do
    specify { expect { described_class.new(nil, bulk_size: 100) }.to raise_error(ArgumentError) }
    specify { expect { described_class.new(nil, bulk_size: 100.kilobytes) }.not_to raise_error }
  end

  describe '#perform' do
    before do
      stub_model(:city)
      stub_index(:places) do
        define_type City do
          field :name
        end
      end
    end

    specify do
      expect(Chewy.client).not_to receive(:bulk)
      subject.perform([])
    end

    specify do
      expect(Chewy.client).to receive(:bulk).with(
        index: 'places',
        type: 'city',
        body: [{index: {id: 42, data: {name: 'Name'}}}]
      )
      subject.perform([{index: {id: 42, data: {name: 'Name'}}}])
    end

    context ':suffix' do
      let(:suffix) { 'suffix' }

      specify do
        expect(Chewy.client).to receive(:bulk).with(
          index: 'places_suffix',
          type: 'city',
          body: [{index: {id: 42, data: {name: 'Name'}}}]
        )
        subject.perform([{index: {id: 42, data: {name: 'Name'}}}])
      end
    end

    context ':bulk_size' do
      let(:bulk_size) { 1.2.kilobyte }

      specify do
        expect(Chewy.client).to receive(:bulk).with(
          index: 'places',
          type: 'city',
          body: "{\"index\":{\"id\":42}}\n{\"name\":\"#{'Name' * 10}\"}\n{\"index\":{\"id\":43}}\n{\"name\":\"#{'Shame' * 10}\"}\n"
        )
        subject.perform([
          {index: {id: 42, data: {name: 'Name' * 10}}},
          {index: {id: 43, data: {name: 'Shame' * 10}}}
        ])
      end

      specify do
        expect(Chewy.client).to receive(:bulk).with(
          index: 'places',
          type: 'city',
          body: "{\"index\":{\"id\":42}}\n{\"name\":\"#{'Name' * 30}\"}\n"
        )
        expect(Chewy.client).to receive(:bulk).with(
          index: 'places',
          type: 'city',
          body: "{\"index\":{\"id\":43}}\n{\"name\":\"#{'Shame' * 100}\"}\n"
        )
        expect(Chewy.client).to receive(:bulk).with(
          index: 'places',
          type: 'city',
          body: "{\"index\":{\"id\":44}}\n{\"name\":\"#{'Blame' * 30}\"}\n"
        )
        subject.perform([
          {index: {id: 42, data: {name: 'Name' * 30}}},
          {index: {id: 43, data: {name: 'Shame' * 100}}},
          {index: {id: 44, data: {name: 'Blame' * 30}}}
        ])
      end
    end

    context 'bulk_options' do
      let(:bulk_options) { {refresh: true} }

      specify do
        expect(Chewy.client).to receive(:bulk).with(hash_including(bulk_options))
        subject.perform([{index: {id: 42, data: {name: 'Name'}}}])
      end
    end
  end
end
