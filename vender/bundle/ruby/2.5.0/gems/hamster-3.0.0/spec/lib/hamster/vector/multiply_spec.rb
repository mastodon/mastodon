require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#*" do
    let(:vector) { V[1, 2, 3] }

    context "with a String argument" do
      it "acts just like #join" do
        (vector * 'boo').should eql(vector.join('boo'))
      end
    end

    context "with an Integer argument" do
      it "concatenates n copies of the array" do
        (vector * 0).should eql(V.empty)
        (vector * 1).should eql(vector)
        (vector * 2).should eql(V[1,2,3,1,2,3])
        (vector * 3).should eql(V[1,2,3,1,2,3,1,2,3])
      end

      it "raises an ArgumentError if integer is negative" do
        -> { vector * -1 }.should raise_error(ArgumentError)
      end

      it "works on large vectors" do
        array = (1..50).to_a
        (V.new(array) * 25).should eql(V.new(array * 25))
      end
    end

    context "with a subclass of Vector" do
      it "returns an instance of the subclass" do
        subclass = Class.new(Hamster::Vector)
        instance = subclass.new([1,2,3])
        (instance * 10).class.should be(subclass)
      end
    end

    it "raises a TypeError if passed nil" do
      -> { vector * nil }.should raise_error(TypeError)
    end

    it "raises an ArgumentError if passed no arguments" do
      -> { vector.* }.should raise_error(ArgumentError)
    end
  end
end