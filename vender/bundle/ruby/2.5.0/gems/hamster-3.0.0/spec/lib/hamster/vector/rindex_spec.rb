require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#rindex" do
    let(:vector) { V[1,2,3,3,2,1] }

    context "when passed an object present in the vector" do
      it "returns the last index where the object is present" do
        vector.rindex(1).should be(5)
        vector.rindex(2).should be(4)
        vector.rindex(3).should be(3)
      end
    end

    context "when passed an object not present in the vector" do
      it "returns nil" do
        vector.rindex(0).should be_nil
        vector.rindex(nil).should be_nil
        vector.rindex('string').should be_nil
      end
    end

    context "with a block" do
      it "returns the last index of an object which the predicate is true for" do
        vector.rindex { |n| n > 2 }.should be(3)
      end
    end

    context "without an argument OR block" do
      it "returns an Enumerator" do
        vector.rindex.class.should be(Enumerator)
        vector.rindex.each { |n| n > 2 }.should be(3)
      end
    end
  end
end