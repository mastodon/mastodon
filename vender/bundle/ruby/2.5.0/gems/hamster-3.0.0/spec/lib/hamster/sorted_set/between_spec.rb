require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#between" do
    context "when called without a block" do
      it "returns a sorted set of all items from the first argument to the second" do
        100.times do
          items   = rand(100).times.collect { rand(1000) }
          set     = SS.new(items)
          from,to = [rand(1000),rand(1000)].sort
          result  = set.between(from, to)
          array   = items.select { |x| x >= from && x <= to }.sort
          result.class.should be(Hamster::SortedSet)
          result.size.should == array.size
          result.to_a.should == array
        end
      end
    end

    context "when called with a block" do
      it "yields all the items lower than the argument" do
        100.times do
          items   = rand(100).times.collect { rand(1000) }
          set     = SS.new(items)
          from,to = [rand(1000),rand(1000)].sort
          result  = []
          set.between(from, to) { |x| result << x }
          array  = items.select { |x| x >= from && x <= to }.sort
          result.size.should == array.size
          result.should == array
        end
      end
    end

    context "on an empty set" do
      it "returns an empty set" do
        SS.empty.between(1, 2).should be_empty
        SS.empty.between('abc', 'def').should be_empty
        SS.empty.between(:symbol, :another).should be_empty
      end
    end

    context "with a 'to' argument lower than the 'from' argument" do
      it "returns an empty set" do
        result = SS.new(1..100).between(6, 5)
        result.class.should be(Hamster::SortedSet)
        result.should be_empty
      end
    end
  end
end