require "spec_helper"
require "hamster/list"

describe Hamster::List do
  let(:list) { L[*values] }
  let(:found_list) { L[*found_values] }

  describe "#find_all" do
    it "is lazy" do
      expect { Hamster.stream { fail }.find_all { |item| false } }.to_not raise_error
    end

    shared_examples "checking values" do
      context "with a block" do
        let(:find_all) { list.find_all { |item| item == item.upcase } }

        it "preserves the original" do
          expect(list).to eq(L[*values])
        end

        it "returns the found list" do
          expect(find_all).to eq(found_list)
        end
      end

      context "without a block" do
        let(:find_all) { list.find_all }

        it "returns an Enumerator" do
          expect(find_all.class).to be(Enumerator)
          expect(find_all.each { |item| item == item.upcase }).to eq(found_list)
        end
      end
    end

    context "with an empty array" do
      let(:values) { [] }
      let(:found_values) { [] }

      include_examples "checking values"
    end

    context "with a single item array" do
      let(:values) { ["A"] }
      let(:found_values) { ["A"] }

      include_examples "checking values"
    end

    context "with a multi-item array" do
      let(:values) { %w[A B] }
      let(:found_values) { %w[A B] }

      include_examples "checking values"
    end

    context "with a multi-item single find_allable array" do
      let(:values) { %w[A b] }
      let(:found_values) { ["A"] }

      include_examples "checking values"
    end

    context "with a multi-item multi-find_allable array" do
      let(:values) { %w[a b] }
      let(:found_values) { [] }

      include_examples "checking values"
    end
  end
end
