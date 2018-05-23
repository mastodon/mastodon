require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  let(:vector) { V[*values] }

  describe "#length" do
    let(:length) { vector.length }

    shared_examples "checking size" do
      it "returns the values" do
        expect(length).to eq(size)
      end
    end

    context "with an empty vector" do
      let(:values) { [] }
      let(:size) { 0 }

      include_examples "checking size"
    end

    context "with a single item vector" do
      let(:values) { %w[A] }
      let(:size) { 1 }

      include_examples "checking size"
    end

    context "with a multi-item vector" do
      let(:values) { %w[A B] }
      let(:size) { 2 }

      include_examples "checking size"
    end

    [31, 32, 33, 1023, 1024, 1025].each do |size|
      context "with a #{size}-item vector" do
        let(:values) { (1..size).to_a }
        let(:size) { size }

        include_examples "checking size"
      end
    end
  end
end
