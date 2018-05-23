require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#all?" do
    context "on a really big list" do
      let(:list) { Hamster.interval(0, STACK_OVERFLOW_DEPTH) }

      it "doesn't run out of stack" do
        -> { list.all? }.should_not raise_error
      end
    end

    context "when empty" do
      it "with a block returns true" do
        L.empty.all? {}.should == true
      end

      it "with no block returns true" do
        L.empty.all?.should == true
      end
    end

    context "when not empty" do
      context "with a block" do
        let(:list) { L["A", "B", "C"] }

        context "if the block always returns true" do
          it "returns true" do
            list.all? { |item| true }.should == true
          end
        end

        context "if the block ever returns false" do
          it "returns false" do
            list.all? { |item| item == "D" }.should == false
          end
        end
      end

      context "with no block" do
        context "if all values are truthy" do
          it "returns true" do
            L[true, "A"].all?.should == true
          end
        end

        [nil, false].each do |value|
          context "if any value is #{value.inspect}" do
            it "returns false" do
              L[value, true, "A"].all?.should == false
            end
          end
        end
      end
    end
  end
end