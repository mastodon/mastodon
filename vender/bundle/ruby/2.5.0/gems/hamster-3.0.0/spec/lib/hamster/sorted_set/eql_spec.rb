require "spec_helper"
require "set"
require "hamster/set"

describe Hamster::SortedSet do
  let(:set) { SS[*values] }
  let(:comparison) { SS[*comparison_values] }

  describe "#eql?" do
    let(:eql?) { set.eql?(comparison) }

    shared_examples "comparing something which is not a sorted set" do
      let(:values) { %w[A B C] }

      it "returns false" do
        expect(eql?).to eq(false)
      end
    end

    context "when comparing to a standard set" do
      let(:comparison) { ::Set.new(%w[A B C]) }
      include_examples "comparing something which is not a sorted set"
    end

    context "when comparing to a arbitrary object" do
      let(:comparison) { Object.new }
      include_examples "comparing something which is not a sorted set"
    end

    context "when comparing to a Hamster::Set" do
      let(:comparison) { Hamster::Set.new(%w[A B C]) }
      include_examples "comparing something which is not a sorted set"
    end

    context "when comparing with a subclass of Hamster::SortedSet" do
      let(:comparison) { Class.new(Hamster::SortedSet).new(%w[A B C]) }
      include_examples "comparing something which is not a sorted set"
    end

    context "with an empty set for each comparison" do
      let(:values) { [] }
      let(:comparison_values) { [] }

      it "returns true" do
        expect(eql?).to eq(true)
      end
    end

    context "with an empty set and a set with nil" do
      let(:values) { [] }
      let(:comparison_values) { [nil] }

      it "returns false" do
        expect(eql?).to eq(false)
      end
    end

    context "with a single item array and empty array" do
      let(:values) { ["A"] }
      let(:comparison_values) { [] }

      it "returns false" do
        expect(eql?).to eq(false)
      end
    end

    context "with matching single item array" do
      let(:values) { ["A"] }
      let(:comparison_values) { ["A"] }

      it "returns true" do
        expect(eql?).to eq(true)
      end
    end

    context "with mismatching single item array" do
      let(:values) { ["A"] }
      let(:comparison_values) { ["B"] }

      it "returns false" do
        expect(eql?).to eq(false)
      end
    end

    context "with a multi-item array and single item array" do
      let(:values) { %w[A B] }
      let(:comparison_values) { ["A"] }

      it "returns false" do
        expect(eql?).to eq(false)
      end
    end

    context "with matching multi-item array" do
      let(:values) { %w[A B] }
      let(:comparison_values) { %w[A B] }

      it "returns true" do
        expect(eql?).to eq(true)
      end
    end

    context "with a mismatching multi-item array" do
      let(:values) { %w[A B] }
      let(:comparison_values) { %w[B A] }

      it "returns true" do
        expect(eql?).to eq(true)
      end
    end

    context "with the same values, but a different sort order" do
      let(:set) { SS[1, 2, 3] }
      let(:comparison) { SS.new([1, 2, 3]) { |n| -n }}

      it "returns false" do
        expect(eql?).to eq(false)
      end
    end
  end
end
