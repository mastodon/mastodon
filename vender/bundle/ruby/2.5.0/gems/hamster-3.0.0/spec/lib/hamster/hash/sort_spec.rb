require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  let(:hash) { H[a: 3, b: 2, c: 1] }

  describe "#sort" do
    it "returns a Vector of sorted key/val pairs" do
      hash.sort.should eql(V[[:a, 3], [:b, 2], [:c, 1]])
    end

    it "works on large hashes" do
      array = (1..1000).map { |n| [n,n] }
      H.new(array.shuffle).sort.should eql(V.new(array))
    end

    it "uses block as comparator to sort if passed a block" do
      hash.sort { |a,b| b <=> a }.should eql(V[[:c, 1], [:b, 2], [:a, 3]])
    end
  end

  describe "#sort_by" do
    it "returns a Vector of key/val pairs, sorted using the block as a key function" do
      hash.sort_by { |k,v| v }.should eql(V[[:c, 1], [:b, 2], [:a, 3]])
    end
  end
end