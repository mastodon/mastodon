require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#permutation" do
    let(:list) { L[1,2,3,4] }

    context "with no block" do
      it "returns an Enumerator" do
        list.permutation.class.should be(Enumerator)
        list.permutation.to_a.sort.should == [1,2,3,4].permutation.to_a.sort
      end
    end

    context "with no argument" do
      it "yields all permutations of the list" do
        perms = list.permutation.to_a
        perms.size.should be(24)
        perms.sort.should == [1,2,3,4].permutation.to_a.sort
        perms.each { |item| item.should be_kind_of(Hamster::List) }
      end
    end

    context "with a length argument" do
      it "yields all N-size permutations of the list" do
        perms = list.permutation(2).to_a
        perms.size.should be(12)
        perms.sort.should == [1,2,3,4].permutation(2).to_a.sort
        perms.each { |item| item.should be_kind_of(Hamster::List) }
      end
    end

    context "with a length argument greater than length of list" do
      it "yields nothing" do
        list.permutation(5).to_a.should be_empty
      end
    end

    context "with a length argument of 0" do
      it "yields an empty list" do
        perms = list.permutation(0).to_a
        perms.size.should be(1)
        perms[0].should be_kind_of(Hamster::List)
        perms[0].should be_empty
      end
    end

    context "with a block" do
      it "returns the original list" do
        list.permutation(0) {}.should be(list)
        list.permutation(1) {}.should be(list)
        list.permutation {}.should be(list)
      end
    end
  end
end