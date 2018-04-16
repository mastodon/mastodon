require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#from" do
    context "when called without a block" do
      it "returns a sorted set of all items equal to or greater than the argument" do
        100.times do
          items     = rand(100).times.collect { rand(1000) }
          set       = SS.new(items)
          threshold = rand(1000)
          result    = set.from(threshold)
          array     = items.select { |x| x >= threshold }.sort
          result.class.should be(Hamster::SortedSet)
          result.size.should == array.size
          result.to_a.should == array
        end
      end
    end

    context "when called with a block" do
      it "yields all the items equal to or greater than than the argument" do
        100.times do
          items     = rand(100).times.collect { rand(1000) }
          set       = SS.new(items)
          threshold = rand(1000)
          result    = []
          set.from(threshold) { |x| result << x }
          array  = items.select { |x| x >= threshold }.sort
          result.size.should == array.size
          result.should == array
        end
      end
    end

    context "on an empty set" do
      it "returns an empty set" do
        SS.empty.from(1).should be_empty
        SS.empty.from('abc').should be_empty
        SS.empty.from(:symbol).should be_empty
      end
    end

    context "with an argument higher than all the values in the set" do
      it "returns an empty set" do
        result = SS.new(1..100).from(101)
        result.class.should be(Hamster::SortedSet)
        result.should be_empty
      end
    end
  end
end