require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  describe "#none?" do
    context "when empty" do
      it "with a block returns true" do
        H.empty.none? {}.should == true
      end

      it "with no block returns true" do
        H.empty.none?.should == true
      end
    end

    context "when not empty" do
      let(:hash) { H["A" => "aye", "B" => "bee", "C" => "see", nil => "NIL"] }

      context "with a block" do
        [
          %w[A aye],
          %w[B bee],
          %w[C see],
          [nil, "NIL"],
        ].each do |pair|
          it "returns false if the block ever returns true (#{pair.inspect})" do
            hash.none? { |key, value| key == pair.first && value == pair.last }.should == false
          end

          it "returns true if the block always returns false" do
            hash.none? { |key, value| key == "D" && value == "dee" }.should == true
          end

          it "stops iterating as soon as the block returns true" do
            yielded = []
            hash.none? { |k,v| yielded << k; true }
            yielded.size.should == 1
          end
        end
      end

      context "with no block" do
        it "returns false" do
          hash.none?.should == false
        end
      end
    end
  end
end
