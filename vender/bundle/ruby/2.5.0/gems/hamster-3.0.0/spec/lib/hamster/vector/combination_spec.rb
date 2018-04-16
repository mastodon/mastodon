require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#combination" do
    let(:vector) { V[1,2,3,4] }

    context "with a block" do
      it "returns self" do
        vector.combination(2) {}.should be(vector)
      end
    end

    context "with no block" do
      it "returns an Enumerator" do
        vector.combination(2).class.should be(Enumerator)
        vector.combination(2).to_a.should == vector.to_a.combination(2).to_a
      end
    end

    context "when passed an argument which is out of bounds" do
      it "yields nothing and returns self" do
        vector.combination(5) { fail }.should be(vector)
        vector.combination(-1) { fail }.should be(vector)
      end
    end

    context "when passed an argument zero" do
      it "yields an empty array" do
        result = []
        vector.combination(0) { |obj| result << obj }
        result.should eql([[]])
      end
    end

    context "when passed an argument equal to the vector's length" do
      it "yields self as an array" do
        result = []
        vector.combination(4) { |obj| result << obj }
        result.should eql([vector.to_a])
      end
    end

    context "when passed an argument 1" do
      it "yields each item in the vector, as single-item vectors" do
        result = []
        vector.combination(1) { |obj| result << obj }
        result.should eql([[1], [2], [3], [4]])
      end
    end

    context "when passed another integral argument" do
      it "yields all combinations of the given length" do
        result = []
        vector.combination(3) { |obj| result << obj }
        result.should eql([[1,2,3], [1,2,4], [1,3,4], [2,3,4]])
      end
    end

    context "on an empty vector" do
      it "works the same" do
        V.empty.combination(0).to_a.should == [[]]
        V.empty.combination(1).to_a.should == []
      end
    end

    it "works on many combinations of input" do
      0.upto(5) do |comb_size|
        array = 12.times.map { rand(1000) }
        V.new(array).combination(comb_size).to_a.should == array.combination(comb_size).to_a
      end

      array = 20.times.map { rand(1000) }
      V.new(array).combination(2).to_a.should == array.combination(2).to_a
    end

    it "leaves the original unmodified" do
      vector.combination(2) {}
      vector.should eql(V[1,2,3,4])
    end
  end
end