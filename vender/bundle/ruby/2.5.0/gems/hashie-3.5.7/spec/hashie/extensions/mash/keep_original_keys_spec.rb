require 'spec_helper'

RSpec.describe Hashie::Extensions::Mash::KeepOriginalKeys do
  let(:keeping_mash) do
    Class.new(Hashie::Mash) do
      include Hashie::Extensions::Mash::KeepOriginalKeys
    end
  end

  it 'keeps the keys in the resulting hash identical to the original' do
    original = { :a => 'apple', 'b' => 'bottle' }
    mash = keeping_mash.new(original)

    expect(mash.to_hash).to eq(original)
  end

  it 'indifferently responds to keys' do
    original = { :a => 'apple', 'b' => 'bottle' }
    mash = keeping_mash.new(original)

    expect(mash['a']).to eq(mash[:a])
    expect(mash['b']).to eq(mash[:b])
  end

  it 'responds to all method accessors like a Mash' do
    original = { :a => 'apple', 'b' => 'bottle' }
    mash = keeping_mash.new(original)

    expect(mash.a).to eq('apple')
    expect(mash.a?).to eq(true)
    expect(mash.b).to eq('bottle')
    expect(mash.b?).to eq(true)
    expect(mash.underbang_).to be_a(keeping_mash)
    expect(mash.bang!).to be_a(keeping_mash)
    expect(mash.predicate?).to eq(false)
  end

  it 'keeps the keys that are directly passed without converting them' do
    original = { :a => 'apple', 'b' => 'bottle' }
    mash = keeping_mash.new(original)

    mash[:c] = 'cat'
    mash['d'] = 'dog'
    expect(mash.to_hash).to eq(:a => 'apple', 'b' => 'bottle', :c => 'cat', 'd' => 'dog')
  end
end
