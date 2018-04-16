require "spec_helper"
require "hamster/deque"

describe Hamster::Deque do
  describe "#empty?" do
    [
      [[], true],
      [["A"], false],
      [%w[A B C], false],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        it "returns #{expected.inspect}" do
          D[*values].empty?.should == expected
        end
      end
    end

    context "after dedequeing an item from #{%w[A B C].inspect}" do
      it "returns false" do
        D["A", "B", "C"].dequeue.should_not be_empty
      end
    end
  end

  describe ".empty" do
    it "returns the canonical empty deque" do
      D.empty.size.should be(0)
      D.empty.class.should be(Hamster::Deque)
      D.empty.object_id.should be(Hamster::EmptyDeque.object_id)
    end

    context "from a subclass" do
      it "returns an empty instance of the subclass" do
        subclass = Class.new(Hamster::Deque)
        subclass.empty.class.should be(subclass)
        subclass.empty.should be_empty
      end
    end
  end
end