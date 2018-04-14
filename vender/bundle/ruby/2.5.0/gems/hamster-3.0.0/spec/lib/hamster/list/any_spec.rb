require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#any?" do
    context "on a really big list" do
      let(:list) { Hamster.interval(0, STACK_OVERFLOW_DEPTH) }

      it "doesn't run out of stack" do
        -> { list.any? { false } }.should_not raise_error
      end
    end

    context "when empty" do
      it "with a block returns false" do
       L.empty.any? {}.should == false
      end

      it "with no block returns false" do
        L.empty.any?.should == false
      end
    end

    context "when not empty" do
      context "with a block" do
        let(:list) { L["A", "B", "C", nil] }

        ["A", "B", "C", nil].each do |value|
          it "returns true if the block ever returns true (#{value.inspect})" do
            list.any? { |item| item == value }.should == true
          end
        end

        it "returns false if the block always returns false" do
          list.any? { |item| item == "D" }.should == false
        end
      end

      context "with no block" do
        it "returns true if any value is truthy" do
          L[nil, false, "A", true].any?.should == true
        end

        it "returns false if all values are falsey" do
          L[nil, false].any?.should == false
        end
      end
    end
  end
end