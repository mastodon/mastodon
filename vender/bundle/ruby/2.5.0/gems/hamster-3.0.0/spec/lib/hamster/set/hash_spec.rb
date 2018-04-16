require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  describe "#hash" do
    context "on an empty set" do
      it "returns 0" do
        S.empty.hash.should == 0
      end
    end

    it "generates the same hash value for a set regardless of the order things were added to it" do
      item1 = DeterministicHash.new('a', 121)
      item2 = DeterministicHash.new('b', 474)
      item3 = DeterministicHash.new('c', 121)
      S.empty.add(item1).add(item2).add(item3).hash.should == S.empty.add(item3).add(item2).add(item1).hash
    end

    it "values are sufficiently distributed" do
      (1..4000).each_slice(4).map { |a, b, c, d| S[a, b, c, d].hash }.uniq.size.should == 1000
    end
  end
end
