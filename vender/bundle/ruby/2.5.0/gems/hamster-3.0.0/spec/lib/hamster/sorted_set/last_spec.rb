require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  let(:sorted_set) { SS[*values] }

  describe "#last" do
    let(:last) { sorted_set.last }

    shared_examples "checking values" do
      it "returns the last item" do
        expect(last).to eq(last_item)
      end
    end

    context "with an empty set" do
      let(:last_item) { nil }
      let(:values) { [] }

      include_examples "checking values"
    end

    context "with a single item set" do
      let(:last_item) { "A" }
      let(:values) { %w[A] }

      include_examples "checking values"
    end

    context "with a multi-item set" do
      let(:last_item) { "B" }
      let(:values) { %w[B A] }

      include_examples "checking values"
    end
  end
end
