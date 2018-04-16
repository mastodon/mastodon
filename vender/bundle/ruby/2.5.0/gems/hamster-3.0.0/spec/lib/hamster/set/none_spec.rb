require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  describe "#none?" do
    context "when empty" do
      it "with a block returns true" do
        S.empty.none? {}.should == true
      end

      it "with no block returns true" do
        S.empty.none?.should == true
      end
    end

    context "when not empty" do
      context "with a block" do
        let(:set) { S["A", "B", "C", nil] }

        ["A", "B", "C", nil].each do |value|
          it "returns false if the block ever returns true (#{value.inspect})" do
            set.none? { |item| item == value }.should == false
          end
        end

        it "returns true if the block always returns false" do
          set.none? { |item| item == "D" }.should == true
        end

        it "stops iterating as soon as the block returns true" do
          yielded = []
          set.none? { |item| yielded << item; true }
          yielded.size.should == 1
        end
      end

      context "with no block" do
        it "returns false if any value is truthy" do
          S[nil, false, true, "A"].none?.should == false
        end

        it "returns true if all values are falsey" do
          S[nil, false].none?.should == true
        end
      end
    end
  end
end