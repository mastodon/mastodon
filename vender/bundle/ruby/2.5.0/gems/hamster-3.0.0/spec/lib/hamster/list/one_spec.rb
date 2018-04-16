require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#one?" do
    context "on a really big list" do
      it "doesn't run out of stack" do
        -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).one? { false } }.should_not raise_error
      end
    end

    context "when empty" do
      it "with a block returns false" do
        L.empty.one? {}.should == false
      end

      it "with no block returns false" do
        L.empty.one?.should == false
      end
    end

    context "when not empty" do
      context "with a block" do
        let(:list) { L["A", "B", "C"] }

        it "returns false if the block returns true more than once" do
          list.one? { |item| true }.should == false
        end

        it "returns false if the block never returns true" do
          list.one? { |item| false }.should == false
        end

        it "returns true if the block only returns true once" do
          list.one? { |item| item == "A" }.should == true
        end
      end

      context "with no block" do
        it "returns false if more than one value is truthy" do
          L[nil, true, "A"].one?.should == false
        end

        it "returns true if only one value is truthy" do
          L[nil, true, false].one?.should == true
        end
      end
    end
  end
end