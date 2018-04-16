require "spec_helper"
require "set"
require "hamster/set"

describe Hamster::Set do
  let(:set) { S["A", "B", "C"] }

  describe "#each" do
    let(:each) { set.each(&block) }

    context "without a block" do
      let(:block) { nil }

      it "returns an Enumerator" do
        expect(each.class).to be(Enumerator)
        expect(each.to_a).to eq(set.to_a)
      end
    end

    context "with an empty block" do
      let(:block) { ->(item) {} }

      it "returns self" do
        expect(each).to be(set)
      end
    end

    context "with a block" do
      let(:items)  { ::Set.new }
      let(:values) { ::Set.new(%w[A B C]) }
      let(:block)  { ->(item) { items << item } }
      before(:each) { each }

      it "yields all values" do
        expect(items).to eq(values)
      end
    end

    it "yields both of a pair of colliding keys" do
      set = S[DeterministicHash.new('a', 1010), DeterministicHash.new('b', 1010)]
      yielded = []
      set.each { |obj| yielded << obj }
      yielded.map(&:value).sort.should == ['a', 'b']
    end
  end
end
