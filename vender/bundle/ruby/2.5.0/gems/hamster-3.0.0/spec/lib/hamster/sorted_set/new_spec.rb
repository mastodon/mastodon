require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe ".new" do
    it "accepts a single enumerable argument and creates a new sorted set" do
      sorted_set = SS.new([1,2,3])
      sorted_set.size.should be(3)
      sorted_set[0].should be(1)
      sorted_set[1].should be(2)
      sorted_set[2].should be(3)
    end

    it "also works with a Range" do
      sorted_set = SS.new(1..3)
      sorted_set.size.should be(3)
      sorted_set[0].should be(1)
      sorted_set[1].should be(2)
      sorted_set[2].should be(3)
    end

    it "is amenable to overriding of #initialize" do
      class SnazzySortedSet < Hamster::SortedSet
        def initialize
          super(['SNAZZY!!!'])
        end
      end

      sorted_set = SnazzySortedSet.new
      sorted_set.size.should be(1)
      sorted_set.to_a.should == ['SNAZZY!!!']
    end

    it "accepts a block with arity 1" do
      sorted_set = SS.new(1..3) { |a| -a }
      sorted_set[0].should be(3)
      sorted_set[1].should be(2)
      sorted_set[2].should be(1)
    end

    it "accepts a block with arity 2" do
      sorted_set = SS.new(1..3) { |a,b| b <=> a }
      sorted_set[0].should be(3)
      sorted_set[1].should be(2)
      sorted_set[2].should be(1)
    end

    it "can use a block produced by Symbol#to_proc" do
      sorted_set = SS.new([Object, BasicObject], &:name.to_proc)
      sorted_set[0].should be(BasicObject)
      sorted_set[1].should be(Object)
    end

    context "from a subclass" do
      it "returns a frozen instance of the subclass" do
        subclass = Class.new(Hamster::SortedSet)
        instance = subclass.new(["some", "values"])
        instance.class.should be subclass
        instance.frozen?.should be true
      end
    end
  end

  describe ".[]" do
    it "accepts a variable number of items and creates a new sorted set" do
      sorted_set = SS['a', 'b']
      sorted_set.size.should be(2)
      sorted_set[0].should == 'a'
      sorted_set[1].should == 'b'
    end
  end
end