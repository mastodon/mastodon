require "spec_helper"
require "hamster/deque"

describe Hamster::Deque do
  describe ".[]" do
    context "with no arguments" do
      it "always returns the same instance" do
        D[].class.should be(Hamster::Deque)
        D[].should equal(D[])
      end

      it "returns an empty, frozen deque" do
        D[].should be_empty
        D[].should be_frozen
      end
    end

    context "with a number of items" do
      let(:deque) { D["A", "B", "C"] }

      it "always returns a different instance" do
        deque.should_not equal(D["A", "B", "C"])
      end

      it "is the same as repeatedly using #endeque" do
        deque.should eql(D.empty.enqueue("A").enqueue("B").enqueue("C"))
      end
    end
  end
end