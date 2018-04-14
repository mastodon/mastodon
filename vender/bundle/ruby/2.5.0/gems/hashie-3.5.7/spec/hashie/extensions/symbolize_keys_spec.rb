require 'spec_helper'
require 'support/module_context'

def invoke(method)
  if subject == object
    subject.public_send(method)
  else
    subject.public_send(method, object)
  end
end

shared_examples 'symbolize_keys!' do
  it 'converts keys to symbols' do
    object['abc'] = 'abc'
    object['def'] = 'def'
    invoke :symbolize_keys!
    expect((object.keys & [:abc, :def]).size).to eq 2
  end

  it 'converts nested instances of the same class' do
    object['ab'] = dummy_class.new
    object['ab']['cd'] = dummy_class.new
    object['ab']['cd']['ef'] = 'abcdef'
    invoke :symbolize_keys!
    expect(object).to eq(ab: { cd: { ef: 'abcdef' } })
  end

  it 'converts nested hashes' do
    object['ab'] = { 'cd' => { 'ef' => 'abcdef' } }
    invoke :symbolize_keys!
    expect(object).to eq(ab: { cd: { ef: 'abcdef' } })
  end

  it 'performs deep conversion within nested arrays' do
    object['ab'] = []
    object['ab'] << dummy_class.new
    object['ab'] << dummy_class.new
    object['ab'][0]['cd'] = 'abcd'
    object['ab'][1]['ef'] = 'abef'
    new_object = invoke :symbolize_keys
    expect(new_object).to eq(ab: [{ cd: 'abcd' }, { ef: 'abef' }])
  end
end

shared_examples 'symbolize_keys' do
  it 'converts keys to symbols' do
    object['abc'] = 'def'
    copy = invoke :symbolize_keys
    expect(copy[:abc]).to eq 'def'
  end

  it 'does not alter the original' do
    object['abc'] = 'def'
    copy = invoke :symbolize_keys
    expect(object.keys).to eq ['abc']
    expect(copy.keys).to eq [:abc]
  end
end

describe Hashie::Extensions::SymbolizeKeys do
  include_context 'included hash module'
  let(:object) { subject }

  describe '#symbolize_keys!' do
    include_examples 'symbolize_keys!'
    let(:object) { subject }

    it 'returns itself' do
      expect(subject.symbolize_keys!).to eq subject
    end
  end

  describe '#symbolize_keys' do
    include_examples 'symbolize_keys'
  end

  context 'class methods' do
    subject { described_class }
    let(:object) { Hash.new }

    describe '.symbolize_keys' do
      include_examples 'symbolize_keys'
    end
    describe '.symbolize_keys!' do
      include_examples 'symbolize_keys!'
    end
  end

  context 'singleton methods' do
    subject { Hash }
    let(:object) { subject.new.merge('a' => 1, 'b' => { 'c' => 2 }).extend(Hashie::Extensions::SymbolizeKeys) }
    let(:expected_hash) { { a: 1, b: { c: 2 } } }

    describe '.symbolize_keys' do
      it 'does not raise error' do
        expect { object.symbolize_keys }.not_to raise_error
      end
      it 'produces expected symbolized hash' do
        expect(object.symbolize_keys).to eq(expected_hash)
      end
    end
    describe '.symbolize_keys!' do
      it 'does not raise error' do
        expect { object.symbolize_keys! }.not_to raise_error
      end
      it 'produces expected symbolized hash' do
        expect(object.symbolize_keys!).to eq(expected_hash)
      end
    end
  end
end

describe Hashie do
  let!(:dummy_class) do
    klass = Class.new(::Hash)
    klass.send :include, Hashie::Extensions::StringifyKeys
    klass
  end

  subject { described_class }
  let(:object) { Hash.new }

  describe '.symbolize_keys' do
    include_examples 'symbolize_keys'
  end
  describe '.symbolize_keys!' do
    include_examples 'symbolize_keys!'
  end
end
