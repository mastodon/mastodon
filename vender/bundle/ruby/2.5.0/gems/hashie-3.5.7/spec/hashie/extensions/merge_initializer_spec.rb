require 'spec_helper'

describe Hashie::Extensions::MergeInitializer do
  class MergeInitializerHash < Hash
    include Hashie::Extensions::MergeInitializer
  end

  subject { MergeInitializerHash }

  it 'initializes with no arguments' do
    expect(subject.new).to eq({})
  end

  it 'initializes with a hash' do
    expect(subject.new(abc: 'def')).to eq(abc: 'def')
  end

  it 'initializes with a hash and a default' do
    h = subject.new({ abc: 'def' }, 'bar')
    expect(h[:foo]).to eq 'bar'
    expect(h[:abc]).to eq 'def'
  end
end
