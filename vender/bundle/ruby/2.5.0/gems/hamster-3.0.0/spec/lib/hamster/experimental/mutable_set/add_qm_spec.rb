require "spec_helper"

require "hamster/experimental/mutable_set"

describe Hamster::MutableSet do
  let(:mutable) { Hamster::MutableSet[*values] }

  describe "#add?" do
    let(:values) { %w[A B C] }
    let(:add?) { mutable.add?(value) }

    context "with a unique value" do
      let(:value) { "D" }

      it "returns true" do
        expect(add?).to be true
      end

      it "modifies the set to include the new value" do
        add?
        expect(mutable).to eq(Hamster::MutableSet["A", "B", "C", "D"])
      end

    end

    context "with a duplicate value" do
      let(:value) { "C" }

      it "returns false" do
        expect(add?).to be(false)
      end

      it "preserves the original values" do
        add?
        expect(mutable).to eq(Hamster::MutableSet["A", "B", "C"])
      end
    end
  end
end
