require "spec_helper"
require "hamster/list"

describe Hamster::List do
  let(:list) { L[*values] }
  let(:selected_list) { L[*selected_values] }

  describe "#select" do
    it "is lazy" do
      expect { Hamster.stream { fail }.select { |item| false } }.to_not raise_error
    end

    shared_examples "checking values" do
      context "with a block" do
        let(:select) { list.select { |item| item == item.upcase } }

        it "preserves the original" do
          expect(list).to eq(L[*values])
        end

        it "returns the selected list" do
          expect(select).to eq(selected_list)
        end
      end

      context "without a block" do
        let(:select) { list.select }

        it "returns an Enumerator" do
          expect(select.class).to be(Enumerator)
          expect(select.each { |item| item == item.upcase }).to eq(selected_list)
        end
      end
    end

    context "with an empty array" do
      let(:values) { [] }
      let(:selected_values) { [] }

      include_examples "checking values"
    end

    context "with a single item array" do
      let(:values) { ["A"] }
      let(:selected_values) { ["A"] }

      include_examples "checking values"
    end

    context "with a multi-item array" do
      let(:values) { %w[A B] }
      let(:selected_values) { %w[A B] }

      include_examples "checking values"
    end

    context "with a multi-item single selectable array" do
      let(:values) { %w[A b] }
      let(:selected_values) { ["A"] }

      include_examples "checking values"
    end

    context "with a multi-item multi-selectable array" do
      let(:values) { %w[a b] }
      let(:selected_values) { [] }

      include_examples "checking values"
    end
  end
end
