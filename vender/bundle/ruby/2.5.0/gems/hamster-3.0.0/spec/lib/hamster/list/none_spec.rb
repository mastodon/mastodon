require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#none?" do
    context "on a really big list" do
      it "doesn't run out of stack" do
        -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).none? { false } }.should_not raise_error
      end
    end

    context "when empty" do
      it "with a block returns true" do
        L.empty.none? {}.should == true
      end

      it "with no block returns true" do
        L.empty.none?.should == true
      end
    end

    context "when not empty" do
      context "with a block" do
        let(:list) { L["A", "B", "C", nil] }

        ["A", "B", "C", nil].each do |value|
          it "returns false if the block ever returns true (#{value.inspect})" do
            list.none? { |item| item == value }.should == false
          end
        end

        it "returns true if the block always returns false" do
          list.none? { |item| item == "D" }.should == true
        end
      end

      context "with no block" do
        it "returns false if any value is truthy" do
          L[nil, false, true, "A"].none?.should == false
        end

        it "returns true if all values are falsey" do
          L[nil, false].none?.should == true
        end
      end
    end
  end
end