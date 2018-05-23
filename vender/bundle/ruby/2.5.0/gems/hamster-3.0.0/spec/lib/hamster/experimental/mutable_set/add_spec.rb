require "spec_helper"
require "hamster/experimental/mutable_set"

describe Hamster::MutableSet do
  let(:mutable) { Hamster::MutableSet[*values] }

  describe "#add" do
    let(:values) { %w[A B C] }
    let(:add) { mutable.add(value) }

    context "with a unique value" do
      let(:value) { "D" }

      it "returns self" do
        expect(add).to eq(mutable)
      end

      it "modifies the original set to include new value" do
        add
        expect(mutable).to eq(Hamster::MutableSet["A", "B", "C", "D"])
      end
    end

    context "with a duplicate value" do
      let(:value) { "C" }

      it "returns self" do
        expect(add).to eq(mutable)
      end

      it "preserves the original values" do
        add
        expect(mutable).to eq(Hamster::MutableSet["A", "B", "C"])
      end
    end
  end
end
