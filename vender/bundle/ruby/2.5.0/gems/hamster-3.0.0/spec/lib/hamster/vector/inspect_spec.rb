require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  let(:vector) { V[*values] }

  describe "#inspect" do
    let(:inspect) { vector.inspect }

    shared_examples "checking output" do
      it "returns its contents as a programmer-readable string" do
        expect(inspect).to eq(output)
      end

      it "returns a string which can be eval'd to get back an equivalent vector" do
        expect(eval(inspect)).to eql(vector)
      end
    end

    context "with an empty array" do
      let(:output) { "Hamster::Vector[]" }
      let(:values) { [] }

      include_examples "checking output"
    end

    context "with a single item array" do
      let(:output) { "Hamster::Vector[\"A\"]" }
      let(:values) { %w[A] }

      include_examples "checking output"
    end

    context "with a multi-item array" do
      let(:output) { "Hamster::Vector[\"A\", \"B\"]" }
      let(:values) { %w[A B] }

      include_examples "checking output"
    end

    context "from a subclass" do
      MyVector = Class.new(Hamster::Vector)
      let(:vector) { MyVector.new(values) }
      let(:output) { "MyVector[1, 2]" }
      let(:values) { [1, 2] }

      include_examples "checking output"
    end
  end
end
