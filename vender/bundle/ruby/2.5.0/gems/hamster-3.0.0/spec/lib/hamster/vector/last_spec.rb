require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  let(:vector) { V[*values] }

  describe "#last" do
    let(:last) { vector.last }

    shared_examples "checking values" do
      it "returns the last item" do
        expect(last).to eq(last_item)
      end
    end

    context "with an empty vector" do
      let(:last_item) { nil }
      let(:values) { [] }

      include_examples "checking values"
    end

    context "with a single item vector" do
      let(:last_item) { "A" }
      let(:values) { %w[A] }

      include_examples "checking values"
    end

    context "with a multi-item vector" do
      let(:last_item) { "B" }
      let(:values) { %w[A B] }

      include_examples "checking values"
    end

    [31, 32, 33, 1023, 1024, 1025].each do |size|
      context "with a #{size}-item vector" do
        let(:last_item) { size }
        let(:values) { (1..size).to_a }

        include_examples "checking values"
      end
    end
  end
end
