require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#above" do
    context "when called without a block" do
      it "returns a sorted set of all items higher than the argument" do
        100.times do
          items     = rand(100).times.collect { rand(1000) }
          set       = SS.new(items)
          threshold = rand(1000)
          result    = set.above(threshold)
          array     = items.select { |x| x > threshold }.sort
          result.class.should be(Hamster::SortedSet)
          result.size.should == array.size
          result.to_a.should == array
        end
      end
    end

    context "when called with a block" do
      it "yields all the items higher than the argument" do
        100.times do
          items     = rand(100).times.collect { rand(1000) }
          set       = SS.new(items)
          threshold = rand(1000)
          result    = []
          set.above(threshold) { |x| result << x }
          array  = items.select { |x| x > threshold }.sort
          result.size.should == array.size
          result.should == array
        end
      end
    end

    context "on an empty set" do
      it "returns an empty set" do
        SS.empty.above(1).should be_empty
        SS.empty.above('abc').should be_empty
        SS.empty.above(:symbol).should be_empty
      end
    end

    context "with an argument higher than all the values in the set" do
      it "returns an empty set" do
        result = SS.new(1..100).above(100)
        result.class.should be(Hamster::SortedSet)
        result.should be_empty
      end
    end
  end
end