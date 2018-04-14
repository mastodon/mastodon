require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  let(:hash) { H[values] }

  describe "#all?" do
    context "when empty" do
      let(:values) { H.new }

      context "without a block" do
        it "returns true" do
          hash.all?.should == true
        end
      end

      context "with a block" do
        it "returns true" do
          hash.all? { false }.should == true
        end
      end
    end

    context "when not empty" do
      let(:values) { { "A" => 1, "B" => 2, "C" => 3 } }

      context "without a block" do
        it "returns true" do
          hash.all?.should == true
        end
      end

      context "with a block" do
        it "returns true if the block always returns true" do
          hash.all? { true }.should == true
        end

        it "returns false if the block ever returns false" do
          hash.all? { |k,v| k != 'C' }.should == false
        end

        it "propagates an exception from the block" do
          -> { hash.all? { |k,v| raise "help" } }.should raise_error(RuntimeError)
        end

        it "stops iterating as soon as the block returns false" do
          yielded = []
          hash.all? { |k,v| yielded << k; false }
          yielded.size.should == 1
        end
      end
    end
  end
end