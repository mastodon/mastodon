require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#flatten" do
    it "recursively flattens nested vectors into containing vector" do
      V[V[1], V[2]].flatten.should eql(V[1,2])
      V[V[V[V[V[V[1,2,3]]]]]].flatten.should eql(V[1,2,3])
      V[V[V[1]], V[V[V[2]]]].flatten.should eql(V[1,2])
    end

    it "flattens nested arrays as well" do
      V[[1,2,3],[[4],[5,6]]].flatten.should eql(V[1,2,3,4,5,6])
    end

    context "with an integral argument" do
      it "only flattens down to the specified depth" do
        V[V[V[1,2]]].flatten(1).should eql(V[V[1,2]])
        V[V[V[V[1]], V[2], V[3]]].flatten(2).should eql(V[V[1], 2, 3])
      end
    end

    context "with an argument of zero" do
      it "returns self" do
        vector = V[1,2,3]
        vector.flatten(0).should be(vector)
      end
    end

    context "on a subclass" do
      it "returns an instance of the subclass" do
        subclass = Class.new(Hamster::Vector)
        instance = subclass.new([1,2])
        instance.flatten.class.should be(subclass)
      end
    end

    context "on a vector with no nested vectors" do
      it "returns an unchanged vector" do
        vector = V[1,2,3]
        vector.flatten.should.eql?(V[1,2,3])
      end

      context "on a Vector larger than 32 items initialized with Vector.new" do
        # Regression test, for problem discovered while working on GH issue #182
        it "returns an unchanged vector" do
          vector1,vector2 = 2.times.collect { V.new(0..33) }
          vector1.flatten.should eql(vector2)
        end
      end
    end

    it "leaves the original unmodified" do
      vector = V[1,2,3]
      vector.flatten
      vector.should eql(V[1,2,3])
    end
  end
end