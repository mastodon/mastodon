require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  describe "#all?" do
    context "when empty" do
      it "with a block returns true" do
        S.empty.all? {}.should == true
      end

      it "with no block returns true" do
        S.empty.all?.should == true
      end
    end

    context "when not empty" do
      context "with a block" do
        let(:set) { S["A", "B", "C"] }

        it "returns true if the block always returns true" do
          set.all? { |item| true }.should == true
        end

        it "returns false if the block ever returns false" do
          set.all? { |item| item == "D" }.should == false
        end

        it "propagates an exception from the block" do
          -> { set.all? { |k,v| raise "help" } }.should raise_error(RuntimeError)
        end

        it "stops iterating as soon as the block returns false" do
          yielded = []
          set.all? { |k,v| yielded << k; false }
          yielded.size.should == 1
        end
      end

      describe "with no block" do
        it "returns true if all values are truthy" do
          S[true, "A"].all?.should == true
        end

        [nil, false].each do |value|
          it "returns false if any value is #{value.inspect}" do
            S[value, true, "A"].all?.should == false
          end
        end
      end
    end
  end
end