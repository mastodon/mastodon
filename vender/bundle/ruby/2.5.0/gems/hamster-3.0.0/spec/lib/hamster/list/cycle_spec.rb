require "spec_helper"
require "hamster/list"

describe Hamster do
  describe "#cycle" do
    it "is lazy" do
      -> { Hamster.stream { fail }.cycle }.should_not raise_error
    end

    context "with an empty list" do
      it "returns an empty list" do
        L.empty.cycle.should be_empty
      end
    end

    context "with a non-empty list" do
      let(:list) { L["A", "B", "C"] }

      it "preserves the original" do
        list.cycle
        list.should == L["A", "B", "C"]
      end

      it "infinitely cycles through all values" do
        list.cycle.take(7).should == L["A", "B", "C", "A", "B", "C", "A"]
      end
    end
  end
end