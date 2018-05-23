require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  let(:sorted_set) { SS["A", "B", "C"] }

  describe "#delete" do
    context "on an empty set" do
      it "returns an empty set" do
        SS.empty.delete(0).should be(SS.empty)
      end
    end

    context "with an existing value" do
      it "preserves the original" do
        sorted_set.delete("B")
        sorted_set.should eql(SS["A", "B", "C"])
      end

      it "returns a copy with the remaining of values" do
        sorted_set.delete("B").should eql(SS["A", "C"])
      end
    end

    context "with a non-existing value" do
      it "preserves the original values" do
        sorted_set.delete("D")
        sorted_set.should eql(SS["A", "B", "C"])
      end

      it "returns self" do
        sorted_set.delete("D").should equal(sorted_set)
      end
    end

    context "when removing the last value in a sorted set" do
      it "maintains the set order" do
        ss = SS.new(["peanuts", "jam", "milk"]) { |word| word.length }
        ss = ss.delete("jam").delete("peanuts").delete("milk")
        ss = ss.add("banana").add("sugar").add("spam")
        ss.to_a.should == ['spam', 'sugar', 'banana']
      end

      context "when the set is in natural order" do
        it "returns the canonical empty set" do
          sorted_set.delete("B").delete("C").delete("A").should be(Hamster::EmptySortedSet)
        end
      end
    end

    1.upto(10) do |n|
      values = (1..n).to_a
      values.combination(3) do |to_delete|
        expected = to_delete.reduce(values.dup) { |ary,val| ary.delete(val); ary }
        describe "on #{values.inspect}, when deleting #{to_delete.inspect}" do
          it "returns #{expected.inspect}" do
            set    = SS.new(values)
            result = to_delete.reduce(set) { |s,val| s.delete(val) }
            result.should eql(SS.new(expected))
            result.to_a.should eql(expected)
          end
        end
      end
    end
  end

  describe "#delete?" do
    context "with an existing value" do
      it "preserves the original" do
        sorted_set.delete?("B")
        sorted_set.should eql(SS["A", "B", "C"])
      end

      it "returns a copy with the remaining values" do
        sorted_set.delete?("B").should eql(SS["A", "C"])
      end
    end

    context "with a non-existing value" do
      it "preserves the original values" do
        sorted_set.delete?("D")
        sorted_set.should eql(SS["A", "B", "C"])
      end

      it "returns false" do
        sorted_set.delete?("D").should be(false)
      end
    end
  end
end