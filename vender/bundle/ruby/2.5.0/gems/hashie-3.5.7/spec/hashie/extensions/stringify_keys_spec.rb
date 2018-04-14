require 'spec_helper'
require 'support/module_context'

def invoke(method)
  if subject == object
    subject.public_send(method)
  else
    subject.public_send(method, object)
  end
end

shared_examples 'stringify_keys!' do
  it 'converts keys to strings' do
    object[:abc] = 'abc'
    object[123] = '123'
    invoke :stringify_keys!
    expect((object.keys & %w(abc 123)).size).to eq 2
  end

  it 'converts nested instances of the same class' do
    object[:ab] = dummy_class.new
    object[:ab][:cd] = dummy_class.new
    object[:ab][:cd][:ef] = 'abcdef'
    invoke :stringify_keys!
    expect(object).to eq('ab' => { 'cd' => { 'ef' => 'abcdef' } })
  end

  it 'converts nested hashes' do
    object[:ab] = { cd: { ef: 'abcdef' } }
    invoke :stringify_keys!
    expect(object).to eq('ab' => { 'cd' => { 'ef' => 'abcdef' } })
  end

  it 'converts nested arrays' do
    object[:ab] = []
    object[:ab] << dummy_class.new
    object[:ab] << dummy_class.new
    object[:ab][0][:cd] = 'abcd'
    object[:ab][1][:ef] = 'abef'
    invoke :stringify_keys!
    expect(object).to eq('ab' => [{ 'cd' => 'abcd' }, { 'ef' => 'abef' }])
  end
end

shared_examples 'stringify_keys' do
  it 'converts keys to strings' do
    object[:abc] = 'def'
    copy = invoke :stringify_keys
    expect(copy['abc']).to eq 'def'
  end

  it 'does not alter the original' do
    object[:abc] = 'def'
    copy = invoke :stringify_keys
    expect(object.keys).to eq [:abc]
    expect(copy.keys).to eq %w(abc)
  end
end

describe Hashie::Extensions::StringifyKeys do
  include_context 'included hash module'
  let(:object) { subject }

  describe '#stringify_keys!' do
    include_examples 'stringify_keys!'

    it 'returns itself' do
      expect(subject.stringify_keys!).to eq subject
    end
  end

  context 'class methods' do
    subject { described_class }
    let(:object) { Hash.new }

    describe '.stringify_keys' do
      include_examples 'stringify_keys'
    end
    describe '.stringify_keys!' do
      include_examples 'stringify_keys!'
    end
  end

  context 'singleton methods' do
    subject { Hash }
    let(:object) { subject.new.merge(a: 1, b: { c: 2 }).extend(Hashie::Extensions::StringifyKeys) }
    let(:expected_hash) { { 'a' => 1, 'b' => { 'c' => 2 } } }

    describe '.stringify_keys' do
      it 'does not raise error' do
        expect { object.stringify_keys } .not_to raise_error
      end
      it 'produces expected stringified hash' do
        expect(object.stringify_keys).to eq(expected_hash)
      end
    end
    describe '.stringify_keys!' do
      it 'does not raise error' do
        expect { object.stringify_keys! } .not_to raise_error
      end
      it 'produces expected stringified hash' do
        expect(object.stringify_keys!).to eq(expected_hash)
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

  describe '.stringify_keys' do
    include_examples 'stringify_keys'
  end
  describe '.stringify_keys!' do
    include_examples 'stringify_keys!'
  end
end
