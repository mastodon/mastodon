require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#each" do
    context "with no block" do
      let(:sorted_set) { SS["A", "B", "C"] }

      it "returns an Enumerator" do
        sorted_set.each.class.should be(Enumerator)
        sorted_set.each.to_a.should eql(sorted_set.to_a)
      end
    end

    context "with a block" do
      let(:sorted_set) { SS.new((1..1025).to_a.reverse) }

      it "returns self" do
        sorted_set.each {}.should be(sorted_set)
      end

      it "iterates over the items in order" do
        items = []
        sorted_set.each { |item| items << item }
        items.should == (1..1025).to_a
      end
    end
  end
end