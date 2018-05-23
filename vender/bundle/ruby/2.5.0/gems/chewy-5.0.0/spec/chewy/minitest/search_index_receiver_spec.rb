require 'spec_helper'
require 'chewy/minitest'

describe :search_index_receiver do
  def search_request(item_count = 2, verb: :index)
    items = Array.new(item_count) do |i|
      {
        verb => {_id: i + 1, data: {}}
      }
    end

    [
      {
        body: items
      }
    ]
  end

  def parse_request(request)
    request.map { |r| r[:_id] }
  end

  let(:receiver) do
    SearchIndexReceiver.new
  end

  before do
    stub_index(:dummies) do
      define_type :fizz do
        root value: ->(_o) { {} }
      end

      define_type :buzz do
        root value: ->(_o) { {} }
      end
    end
  end

  context 'catch' do
    specify 'archives more than one type' do
      receiver.catch search_request(2), DummiesIndex::Fizz
      receiver.catch search_request(3), DummiesIndex::Buzz
      expect(receiver.indexes.keys).to match_array([DummiesIndex::Fizz, DummiesIndex::Buzz])
    end
  end

  context 'indexes_for' do
    before do
      receiver.catch search_request(2), DummiesIndex::Fizz
      receiver.catch search_request(3), DummiesIndex::Buzz
    end

    specify 'returns indexes for a specific type' do
      expect(parse_request(receiver.indexes_for(DummiesIndex::Fizz))).to match_array([1, 2])
    end

    specify 'returns only indexes for all types' do
      index_responses = receiver.indexes
      expect(index_responses.keys).to match_array([DummiesIndex::Fizz, DummiesIndex::Buzz])
      expect(parse_request(index_responses.values.flatten)).to match_array([1, 2, 1, 2, 3])
    end
  end

  context 'deletes_for' do
    before do
      receiver.catch search_request(2, verb: :delete), DummiesIndex::Fizz
      receiver.catch search_request(3, verb: :delete), DummiesIndex::Buzz
    end

    specify 'returns deletes for a specific type' do
      expect(receiver.deletes_for(DummiesIndex::Buzz)).to match_array([1, 2, 3])
    end

    specify 'returns only deletes for all types' do
      deletes = receiver.deletes
      expect(deletes.keys).to match_array([DummiesIndex::Fizz, DummiesIndex::Buzz])
      expect(deletes.values.flatten).to match_array([1, 2, 1, 2, 3])
    end
  end

  context 'indexed?' do
    before do
      receiver.catch search_request(1), DummiesIndex::Fizz
    end

    specify 'validates that an object was indexed' do
      dummy = OpenStruct.new(id: 1)
      expect(receiver.indexed?(dummy, DummiesIndex::Fizz)).to be(true)
    end

    specify 'doesn\'t validate than unindexed objects were indexed' do
      dummy = OpenStruct.new(id: 2)
      expect(receiver.indexed?(dummy, DummiesIndex::Fizz)).to be(false)
    end
  end

  context 'deleted?' do
    before do
      receiver.catch search_request(1, verb: :delete), DummiesIndex::Fizz
    end

    specify 'validates than an object was deleted' do
      dummy = OpenStruct.new(id: 1)
      expect(receiver.deleted?(dummy, DummiesIndex::Fizz)).to be(true)
    end

    specify 'doesn\'t validate than undeleted objects were deleted' do
      dummy = OpenStruct.new(id: 2)
      expect(receiver.deleted?(dummy, DummiesIndex::Fizz)).to be(false)
    end
  end

  context 'updated_indexes' do
    specify 'provides a list of indices updated' do
      receiver.catch search_request(2, verb: :delete), DummiesIndex::Fizz
      receiver.catch search_request(3, verb: :delete), DummiesIndex::Buzz
      expect(receiver.updated_indexes).to match_array([DummiesIndex::Fizz, DummiesIndex::Buzz])
    end
  end
end
