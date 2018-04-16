require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  describe "#one?" do
    context "when empty" do
      it "with a block returns false" do
        S.empty.one? {}.should == false
      end

      it "with no block returns false" do
        S.empty.one?.should == false
      end
    end

    context "when not empty" do
      context "with a block" do
        let(:set) { S["A", "B", "C"] }

        it "returns false if the block returns true more than once" do
          set.one? { |item| true }.should == false
        end

        it "returns false if the block never returns true" do
          set.one? { |item| false }.should == false
        end

        it "returns true if the block only returns true once" do
          set.one? { |item| item == "A" }.should == true
        end
      end

      context "with no block" do
        it "returns false if more than one value is truthy" do
          S[nil, true, "A"].one?.should == false
        end

        it "returns true if only one value is truthy" do
          S[nil, true, false].one?.should == true
        end

        it "returns false if no values are truthy" do
          S[nil, false].one?.should == false
        end
      end
    end
  end
end