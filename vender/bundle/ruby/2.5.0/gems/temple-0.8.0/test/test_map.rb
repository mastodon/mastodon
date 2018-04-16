require 'helper'

describe Temple::ImmutableMap do
  it 'has read accessor' do
    hash = Temple::ImmutableMap.new({a: 1},{b: 2, a: 3})
    hash[:a].should.equal 1
    hash[:b].should.equal 2
  end

  it 'has include?' do
    hash = Temple::ImmutableMap.new({a: 1},{b: 2, a: 3})
    hash.should.include :a
    hash.should.include :b
    hash.should.not.include :c
  end

  it 'has values' do
    Temple::ImmutableMap.new({a: 1},{b: 2, a: 3}).values.sort.should.equal [1,2]
  end

  it 'has keys' do
    Temple::ImmutableMap.new({a: 1},{b: 2, a: 3}).keys.should.equal [:a,:b]
  end

  it 'has to_a' do
    Temple::ImmutableMap.new({a: 1},{b: 2, a: 3}).to_a.should.equal [[:a, 1], [:b, 2]]
  end
end

describe Temple::MutableMap do
  it 'has write accessor' do
    parent = {a: 1}
    hash = Temple::MutableMap.new(parent)
    hash[:a].should.equal 1
    hash[:a] = 2
    hash[:a].should.equal 2
    parent[:a].should.equal 1
  end
end
