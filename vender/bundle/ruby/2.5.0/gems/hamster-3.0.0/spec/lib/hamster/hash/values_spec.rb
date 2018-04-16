require "spec_helper"
require "hamster/hash"
require "hamster/set"

describe Hamster::Hash do
  describe "#values" do
    let(:hash) { H["A" => "aye", "B" => "bee", "C" => "see"] }
    let(:result) { hash.values }

    it "returns the keys as a Vector" do
      result.should be_a Hamster::Vector
      result.to_a.sort.should == %w(aye bee see)
    end

    context "with duplicates" do
      let(:hash) { H[:A => 15, :B => 19, :C => 15] }
      let(:result) { hash.values }

      it "returns the keys as a Vector" do
        result.class.should be(Hamster::Vector)
        result.to_a.sort.should == [15, 15, 19]
      end
    end
  end
end