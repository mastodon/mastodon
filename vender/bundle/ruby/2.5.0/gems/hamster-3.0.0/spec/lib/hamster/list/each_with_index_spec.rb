require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#each_with_index" do
    context "with no block" do
      let(:list) { L["A", "B", "C"] }

      it "returns an Enumerator" do
        list.each_with_index.class.should be(Enumerator)
        list.each_with_index.to_a.should == [['A', 0], ['B', 1], ['C', 2]]
      end
    end

    context "with a block" do
      let(:list) { Hamster.interval(1, 1025) }

      it "returns self" do
        list.each_with_index { |item, index| item }.should be(list)
      end

      it "iterates over the items in order, yielding item and index" do
        yielded = []
        list.each_with_index { |item, index| yielded << [item, index] }
        yielded.should == (1..list.size).zip(0..list.size.pred)
      end
    end
  end
end