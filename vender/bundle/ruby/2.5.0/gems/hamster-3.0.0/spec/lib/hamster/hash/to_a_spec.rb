require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  describe "#to_a" do
    it "returns an Array of [key, value] pairs in same order as #each" do
      hash = H[:a => 1, 1 => :a, 3 => :b, :b => 5]
      pairs = []
      hash.each_pair { |k,v| pairs << [k,v] }
      hash.to_a.should be_kind_of(Array)
      hash.to_a.should == pairs
    end
  end
end