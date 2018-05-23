require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  let(:vector) { V[*values] }

  describe "#to_a" do
    let(:to_a) { vector.to_a }

    shared_examples "checking to_a values" do
      it "returns the values" do
        expect(to_a).to eq(values)
      end
    end

    context "with an empty vector" do
      let(:values) { [] }

      include_examples "checking to_a values"
    end

    context "with an single item vector" do
      let(:values) { %w[A] }

      include_examples "checking to_a values"
    end

    context "with an multi-item vector" do
      let(:values) { %w[A B] }

      include_examples "checking to_a values"
    end

    [10, 31, 32, 33, 1000, 1023, 1024, 1025].each do |size|
      context "with a #{size}-item vector" do
        let(:values) { (1..size).to_a }

        include_examples "checking to_a values"
      end
    end
  end
end
