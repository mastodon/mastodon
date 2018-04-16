require 'spec_helper'

describe Hash do
  it 'is convertible to a Hashie::Mash' do
    mash = Hashie::Hash[some: 'hash'].to_mash
    expect(mash.is_a?(Hashie::Mash)).to be_truthy
    expect(mash.some).to eq 'hash'
  end

  it '#stringify_keys! turns all keys into strings' do
    hash = Hashie::Hash[a: 'hey', 123 => 'bob']
    hash.stringify_keys!
    expect(hash).to eq Hashie::Hash['a' => 'hey', '123' => 'bob']
  end

  it '#stringify_keys! turns all keys into strings recursively' do
    hash = Hashie::Hash[a: 'hey', 123 => { 345 => 'hey' }]
    hash.stringify_keys!
    expect(hash).to eq Hashie::Hash['a' => 'hey', '123' => { '345' => 'hey' }]
  end

  it '#stringify_keys returns a hash with stringified keys' do
    hash = Hashie::Hash[a: 'hey', 123 => 'bob']
    stringified_hash = hash.stringify_keys
    expect(hash).to eq Hashie::Hash[a: 'hey', 123 => 'bob']
    expect(stringified_hash).to eq Hashie::Hash['a' => 'hey', '123' => 'bob']
  end

  it '#to_hash returns a hash with same keys' do
    hash = Hashie::Hash['a' => 'hey', 123 => 'bob', 'array' => [1, 2, 3]]
    stringified_hash = hash.to_hash
    expect(stringified_hash).to eq('a' => 'hey', 123 => 'bob', 'array' => [1, 2, 3])
  end

  it '#to_hash with stringify_keys set to true returns a hash with stringified_keys' do
    hash = Hashie::Hash['a' => 'hey', 123 => 'bob', 'array' => [1, 2, 3]]
    symbolized_hash = hash.to_hash(stringify_keys: true)
    expect(symbolized_hash).to eq('a' => 'hey', '123' => 'bob', 'array' => [1, 2, 3])
  end

  it '#to_hash with symbolize_keys set to true returns a hash with symbolized keys' do
    hash = Hashie::Hash['a' => 'hey', 123 => 'bob', 'array' => [1, 2, 3]]
    symbolized_hash = hash.to_hash(symbolize_keys: true)
    expect(symbolized_hash).to eq(a: 'hey', :"123" => 'bob', array: [1, 2, 3])
  end

  it "#to_hash should not blow up when #to_hash doesn't accept arguments" do
    class BareCustomMash < Hashie::Mash
      def to_hash
        {}
      end
    end

    h = Hashie::Hash.new
    h[:key] = BareCustomMash.new
    expect { h.to_hash }.not_to raise_error
  end

  describe 'when the value is an object that respond_to to_hash' do
    class ClassRespondsToHash
      def to_hash(options = {})
        Hashie::Hash['a' => 'hey', b: 'bar', 123 => 'bob', 'array' => [1, 2, 3]].to_hash(options)
      end
    end

    it '#to_hash returns a hash with same keys' do
      hash = Hashie::Hash['a' => 'hey', 123 => 'bob', 'array' => [1, 2, 3], subhash: ClassRespondsToHash.new]
      stringified_hash = hash.to_hash
      expect(stringified_hash).to eq('a' => 'hey', 123 => 'bob', 'array' => [1, 2, 3], subhash: { 'a' => 'hey', b: 'bar', 123 => 'bob', 'array' => [1, 2, 3] })
    end

    it '#to_hash with stringify_keys set to true returns a hash with stringified_keys' do
      hash = Hashie::Hash['a' => 'hey', 123 => 'bob', 'array' => [1, 2, 3], subhash: ClassRespondsToHash.new]
      symbolized_hash = hash.to_hash(stringify_keys: true)
      expect(symbolized_hash).to eq('a' => 'hey', '123' => 'bob', 'array' => [1, 2, 3], 'subhash' => { 'a' => 'hey', 'b' => 'bar', '123' => 'bob', 'array' => [1, 2, 3] })
    end

    it '#to_hash with symbolize_keys set to true returns a hash with symbolized keys' do
      hash = Hashie::Hash['a' => 'hey', 123 => 'bob', 'array' => [1, 2, 3], subhash: ClassRespondsToHash.new]
      symbolized_hash = hash.to_hash(symbolize_keys: true)
      expect(symbolized_hash).to eq(a: 'hey', :"123" => 'bob', array: [1, 2, 3], subhash: { a: 'hey', b: 'bar', :'123' => 'bob', array: [1, 2, 3] })
    end
  end
end
