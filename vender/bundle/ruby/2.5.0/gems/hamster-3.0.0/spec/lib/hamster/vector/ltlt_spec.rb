require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  let(:vector) { V[*values] }

  describe "#<<" do
    let(:ltlt) { vector << added_value }

    shared_examples "checking adding values" do
      let(:added_vector) { V[*added_values] }

      it "preserves the original" do
        original = vector
        vector << added_value
        expect(original).to eq(vector)
      end

      it "ltlts the item to the vector" do
        expect(ltlt).to eq(added_vector)
      end
    end

    context "with a empty array adding a single item" do
      let(:values) { [] }
      let(:added_value) { "A" }
      let(:added_values) { ["A"] }

      include_examples "checking adding values"
    end

    context "with a single-item array adding a different item" do
      let(:values) { ["A"] }
      let(:added_value) { "B" }
      let(:added_values) { %w[A B] }

      include_examples "checking adding values"
    end

    context "with a single-item array adding a duplicate item" do
      let(:values) { ["A"] }
      let(:added_value) { "A" }
      let(:added_values) { %w[A A] }

      include_examples "checking adding values"
    end

    [31, 32, 33, 1023, 1024, 1025].each do |size|
      context "with a #{size}-item vector adding a different item" do
        let(:values) { (1..size).to_a }
        let(:added_value) { size+1 }
        let(:added_values) { (1..(size+1)).to_a }

        include_examples "checking adding values"
      end
    end

    context "from a subclass" do
      it "returns an instance of the subclass" do
        subclass = Class.new(Hamster::Vector)
        instance = subclass[1,2,3]
        (instance << 4).class.should be(subclass)
      end
    end
  end
end
