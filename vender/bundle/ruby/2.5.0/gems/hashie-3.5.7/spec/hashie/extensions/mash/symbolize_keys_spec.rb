require 'spec_helper'

RSpec.describe Hashie::Extensions::Mash::SymbolizeKeys do
  it 'raises an error when included in a class that is not a Mash' do
    expect do
      Class.new do
        include Hashie::Extensions::Mash::SymbolizeKeys
      end
    end.to raise_error(ArgumentError)
  end

  it 'symbolizes all keys in the Mash' do
    my_mash = Class.new(Hashie::Mash) do
      include Hashie::Extensions::Mash::SymbolizeKeys
    end

    expect(my_mash.new('test' => 'value').to_h).to eq(test: 'value')
  end

  context 'implicit to_hash on double splat' do
    let(:destructure) { ->(**opts) { opts } }
    let(:my_mash) do
      Class.new(Hashie::Mash) do
        include Hashie::Extensions::Mash::SymbolizeKeys
      end
    end
    let(:instance) { my_mash.new('outer' => { 'inner' => 42 }, 'testing' => [1, 2, 3]) }

    subject { destructure.call(instance) }

    it 'is converted on method calls' do
      expect(subject).to eq(outer: { inner: 42 }, testing: [1, 2, 3])
    end

    it 'is converted on explicit operator call' do
      expect(**instance).to eq(outer: { inner: 42 }, testing: [1, 2, 3])
    end
  end
end
