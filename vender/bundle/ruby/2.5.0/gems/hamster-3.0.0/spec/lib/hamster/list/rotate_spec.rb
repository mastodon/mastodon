require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#rotate" do
    let(:list) { L[1,2,3,4,5] }

    context "when passed no argument" do
      it "returns a new list with the first element moved to the end" do
        list.rotate.should eql(L[2,3,4,5,1])
      end
    end

    context "with an integral argument n" do
      it "returns a new list with the first (n % size) elements moved to the end" do
        list.rotate(2).should eql(L[3,4,5,1,2])
        list.rotate(3).should eql(L[4,5,1,2,3])
        list.rotate(4).should eql(L[5,1,2,3,4])
        list.rotate(5).should eql(L[1,2,3,4,5])
        list.rotate(-1).should eql(L[5,1,2,3,4])
      end
    end

    context "with a non-numeric argument" do
      it "raises a TypeError" do
        -> { list.rotate('hello') }.should raise_error(TypeError)
      end
    end

    context "with an argument of zero (or one evenly divisible by list length)" do
      it "it returns self" do
        list.rotate(0).should be(list)
        list.rotate(5).should be(list)
      end
    end
  end
end