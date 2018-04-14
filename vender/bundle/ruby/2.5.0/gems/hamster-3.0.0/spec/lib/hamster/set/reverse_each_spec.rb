require "spec_helper"
require "set"
require "hamster/set"

describe Hamster::Set do
  let(:set) { S["A", "B", "C"] }

  describe "#reverse_each" do
    let(:reverse_each) { set.reverse_each(&block) }

    context "without a block" do
      let(:block) { nil }

      it "returns an Enumerator" do
        expect(reverse_each.class).to be(Enumerator)
        expect(reverse_each.to_a).to eq(set.to_a.reverse)
      end
    end

    context "with an empty block" do
      let(:block) { ->(item) {} }

      it "returns self" do
        expect(reverse_each).to be(set)
      end
    end

    context "with a block" do
      let(:items) { ::Set.new }
      let(:values) { ::Set.new(%w[A B C]) }
      let(:block) { ->(item) { items << item } }
      before(:each) { reverse_each }

      it "yields all values" do
        expect(items).to eq(values)
      end
    end
  end
end
