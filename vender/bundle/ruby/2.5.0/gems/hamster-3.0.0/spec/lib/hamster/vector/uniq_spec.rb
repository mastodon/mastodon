require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#uniq" do
    let(:vector) { V['a', 'b', 'a', 'a', 'c', 'b'] }

    it "returns a vector with no duplicates" do
      vector.uniq.should eql(V['a', 'b', 'c'])
    end

    it "leaves the original unmodified" do
      vector.uniq
      vector.should eql(V['a', 'b', 'a', 'a', 'c', 'b'])
    end

    it "uses #eql? semantics" do
      V[1.0, 1].uniq.should eql(V[1.0, 1])
    end

    it "also uses #hash when determining which values are duplicates" do
      x = double(1)
      x.should_receive(:hash).at_least(1).times.and_return(1)
      y = double(2)
      y.should_receive(:hash).at_least(1).times.and_return(2)
      V[x, y].uniq
    end

    it "keeps the first of each group of duplicate values" do
      x, y, z = 'a', 'a', 'a'
      result = V[x, y, z].uniq
      result.size.should == 1
      result[0].should be(x)
    end

    context "when passed a block" do
      it "uses the return value of the block to determine which items are duplicate" do
        v = V['a', 'A', 'B', 'b']
        v.uniq(&:upcase).should == V['a', 'B']
      end
    end

    context "on a vector with no duplicates" do
      it "returns an unchanged vector" do
        V[1, 2, 3].uniq.should eql(V[1, 2, 3])
      end

      context "if the vector has more than 32 elements and is initialized with Vector.new" do
        # Regression test for GitHub issue #182
        it "returns an unchanged vector" do
          vector1,vector2 = 2.times.collect { V.new(0..36) }
          vector1.uniq.should eql(vector2)
        end
      end
    end

    [10, 31, 32, 33, 1000, 1023, 1024, 1025, 2000].each do |size|
      context "on a #{size}-item vector" do
        it "behaves like Array#uniq" do
          array = size.times.map { rand(size*2) }
          vector = V.new(array)
          result = vector.uniq
          result.should == array.uniq
          result.class.should be(Hamster::Vector)
        end
      end
    end

    context "from a subclass" do
      it "returns an instance of the subclass" do
        subclass = Class.new(Hamster::Vector)
        instance = subclass.new([1,2,3])
        instance.uniq.class.should be(subclass)
      end
    end
  end
end