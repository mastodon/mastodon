require 'spec_helper'

describe Hashie::Rash do
  subject do
    Hashie::Rash.new(
      /hello/ => 'hello',
      /world/ => 'world',
      'other' => 'whee',
      true    => false,
      1       => 'awesome',
      1..1000 => 'rangey',
      /(bcd)/ => proc { |m| m[1] }
    # /.+/ => "EVERYTHING"
    )
  end

  it 'finds strings' do
    expect(subject['other']).to eq 'whee'
    expect(subject['well hello there']).to eq 'hello'
    expect(subject['the world is round']).to eq 'world'
    expect(subject.all('hello world').sort).to eq %w(hello world)
  end

  it 'finds regexps' do
    expect(subject[/other/]).to eq 'whee'
  end

  it 'finds other objects' do
    expect(subject[true]).to eq false
    expect(subject[1]).to eq 'awesome'
  end

  it 'finds numbers from ranges' do
    expect(subject[250]).to eq 'rangey'
    expect(subject[999]).to eq 'rangey'
    expect(subject[1000]).to eq 'rangey'
    expect(subject[1001]).to be_nil
  end

  it 'finds floats from ranges' do
    expect(subject[10.1]).to eq 'rangey'
    expect(subject[1.0]).to eq 'rangey'
    expect(subject[1000.1]).to be_nil
  end

  it 'evaluates proc values' do
    expect(subject['abcdef']).to eq 'bcd'
    expect(subject['ffffff']).to be_nil
  end

  it 'finds using the find method' do
    expect(subject.fetch(10.1)).to eq 'rangey'
    expect(subject.fetch(true)).to be false
  end

  it 'raises in find unless a key matches' do
    expect { subject.fetch(1_000_000) }.to raise_error(KeyError)
  end

  it 'yields in find unless a key matches' do
    expect { |y| subject.fetch(1_000_000, &y) }.to yield_control
    expect { |y| subject.fetch(10.1, &y) }.to_not yield_control
  end

  it 'gives a default value' do
    expect(subject.fetch(10.1, 'noop')).to eq 'rangey'
    expect(subject.fetch(1_000_000, 'noop')).to eq 'noop'
    expect(subject.fetch(1_000_000) { 'noop' }).to eq 'noop'
    expect(subject.fetch(1_000_000) { |k| k }).to eq 1_000_000
    expect(subject.fetch(1_000_000, 'noop') { 'op' }).to eq 'op'
  end

  it 'responds to hash methods' do
    expect(subject.respond_to?(:to_a)).to be true
    expect(subject.methods).to_not include(:to_a)
  end

  it 'does not lose keys' do
    subject.optimize_every = 1
    expect(subject['hello']).to eq('hello')
    expect(subject['world']).to eq('world')
  end
end
