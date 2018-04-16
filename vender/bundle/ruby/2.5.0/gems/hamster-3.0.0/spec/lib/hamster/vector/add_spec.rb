require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  let(:vector) { V[*values] }

  [:add, :<<, :push].each do |method|
    describe "##{method}" do
      shared_examples "checking adding values" do
        let(:added_vector) { V[*added_values] }

        it "preserves the original" do
          original = vector
          vector.send(method, added_value)
          expect(original).to eq(vector)
        end

        it "adds the item to the vector" do
          result = vector.send(method, added_value)
          expect(result).to eq(added_vector)
          expect(result.size).to eq(vector.size + 1)
        end
      end

      context "with a empty vector adding a single item" do
        let(:values) { [] }
        let(:added_value) { "A" }
        let(:added_values) { ["A"] }

        include_examples "checking adding values"
      end

      context "with a single-item vector adding a different item" do
        let(:values) { ["A"] }
        let(:added_value) { "B" }
        let(:added_values) { %w[A B] }

        include_examples "checking adding values"
      end

      context "with a single-item vector adding a duplicate item" do
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
          instance.add(4).class.should be(subclass)
        end
      end
    end
  end
end
