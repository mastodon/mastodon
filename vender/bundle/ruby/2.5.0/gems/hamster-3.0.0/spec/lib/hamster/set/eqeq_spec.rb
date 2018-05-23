require "spec_helper"
require "set"
require "hamster/set"

describe Hamster::Set do
  let(:set) { S[*values] }
  let(:comparison) { S[*comparison_values] }

  describe "#==" do
    let(:eqeq) { set == comparison }

    shared_examples "comparing non-sets" do
      let(:values) { %w[A B C] }

      it "returns false" do
        expect(eqeq).to eq(false)
      end
    end

    context "when comparing to a standard set" do
      let(:comparison) { ::Set.new(%w[A B C]) }

      include_examples "comparing non-sets"
    end

    context "when comparing to a arbitrary object" do
      let(:comparison) { Object.new }

      include_examples "comparing non-sets"
    end

    context "with an empty set for each comparison" do
      let(:values) { [] }
      let(:comparison_values) { [] }

      it "returns true" do
        expect(eqeq).to eq(true)
      end
    end

    context "with an empty set and a set with nil" do
      let(:values) { [] }
      let(:comparison_values) { [nil] }

      it "returns false" do
        expect(eqeq).to eq(false)
      end
    end

    context "with a single item array and empty array" do
      let(:values) { ["A"] }
      let(:comparison_values) { [] }

      it "returns false" do
        expect(eqeq).to eq(false)
      end
    end

    context "with matching single item array" do
      let(:values) { ["A"] }
      let(:comparison_values) { ["A"] }

      it "returns true" do
        expect(eqeq).to eq(true)
      end
    end

    context "with mismatching single item array" do
      let(:values) { ["A"] }
      let(:comparison_values) { ["B"] }

      it "returns false" do
        expect(eqeq).to eq(false)
      end
    end

    context "with a multi-item array and single item array" do
      let(:values) { %w[A B] }
      let(:comparison_values) { ["A"] }

      it "returns false" do
        expect(eqeq).to eq(false)
      end
    end

    context "with matching multi-item array" do
      let(:values) { %w[A B] }
      let(:comparison_values) { %w[A B] }

      it "returns true" do
        expect(eqeq).to eq(true)
      end
    end

    context "with a mismatching multi-item array" do
      let(:values) { %w[A B] }
      let(:comparison_values) { %w[B A] }

      it "returns true" do
        expect(eqeq).to eq(true)
      end
    end
  end
end
