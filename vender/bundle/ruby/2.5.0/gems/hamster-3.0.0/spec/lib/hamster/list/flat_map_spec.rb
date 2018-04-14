require "spec_helper"
require "hamster/list"

describe Hamster::List do
  let(:list) { L[*values] }

  describe "#flat_map" do
    let(:block) { ->(item) { [item, item + 1, item * item] } }
    let(:flat_map) { list.flat_map(&block) }
    let(:flattened_list) { L[*flattened_values] }

    shared_examples "checking flattened result" do

      it "returns the flattened values as a Hamster::List" do
        expect(flat_map).to eq(flattened_list)
      end

      it "returns a Hamster::List" do
        expect(flat_map).to be_a(Hamster::List)
      end
    end

    context "with an empty list" do
      let(:values) { [] }
      let(:flattened_values) { [] }

      include_examples "checking flattened result"
    end

    context "with a block that returns an empty list" do
      let(:block) { ->(item) { [] } }
      let(:values) { [1, 2, 3] }
      let(:flattened_values) { [] }

      include_examples "checking flattened result"
    end

    context "with a list of one item" do
      let(:values) { [7] }
      let(:flattened_values) { [7, 8, 49] }

      include_examples "checking flattened result"
    end

    context "with a list of multiple items" do
      let(:values) { [1, 2, 3] }
      let(:flattened_values) { [1, 2, 1, 2, 3, 4, 3, 4, 9] }

      include_examples "checking flattened result"
    end
  end
end
