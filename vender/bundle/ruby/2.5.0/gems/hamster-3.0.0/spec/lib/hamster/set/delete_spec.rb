require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  let(:set) { S["A", "B", "C"] }

  describe "#delete" do
    context "with an existing value" do
      it "preserves the original" do
        set.delete("B")
        set.should eql(S["A", "B", "C"])
      end

      it "returns a copy with the remaining values" do
        set.delete("B").should eql(S["A", "C"])
      end
    end

    context "with a non-existing value" do
      it "preserves the original values" do
        set.delete("D")
        set.should eql(S["A", "B", "C"])
      end

      it "returns self" do
        set.delete("D").should equal(set)
      end
    end

    context "when removing the last value in a set" do
      it "returns the canonical empty set" do
        set.delete("B").delete("C").delete("A").should be(Hamster::EmptySet)
      end
    end

    it "works on large sets, with many combinations of input" do
      array = 1000.times.map { %w[a b c d e f g h i j k l m n].sample(5).join }.uniq
      set = S.new(array)
      array.each do |key|
        result = set.delete(key)
        result.size.should == set.size - 1
        result.include?(key).should == false
        other = array.sample
        (result.include?(other).should == true) if other != key
      end
    end
  end

  describe "#delete?" do
    context "with an existing value" do
      it "preserves the original" do
        set.delete?("B")
        set.should eql(S["A", "B", "C"])
      end

      it "returns a copy with the remaining values" do
        set.delete?("B").should eql(S["A", "C"])
      end
    end

    context "with a non-existing value" do
      it "preserves the original values" do
        set.delete?("D")
        set.should eql(S["A", "B", "C"])
      end

      it "returns false" do
        set.delete?("D").should be(false)
      end
    end
  end
end