require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#empty?" do
    [
      [[], true],
      [["A"], false],
      [%w[A B C], false],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:sorted_set) { SS[*values] }

        it "returns #{expected.inspect}" do
          sorted_set.empty?.should == expected
        end
      end
    end
  end

  describe ".empty" do
    it "returns the canonical empty set" do
      SS.empty.size.should be(0)
      SS.empty.object_id.should be(SS.empty.object_id)
    end

    context "from a subclass" do
      it "returns an empty instance of the subclass" do
        subclass = Class.new(Hamster::SortedSet)
        subclass.empty.class.should be(subclass)
        subclass.empty.should be_empty
      end
    end
  end
end