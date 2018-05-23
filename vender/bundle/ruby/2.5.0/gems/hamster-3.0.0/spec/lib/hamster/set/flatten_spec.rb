require "spec_helper"
require "hamster/set"

describe Hamster do
  describe "#flatten" do
    [
      [["A"], ["A"]],
      [%w[A B C], %w[A B C]],
      [["A", S["B"], "C"], %w[A B C]],
      [[S["A"], S["B"], S["C"]], %w[A B C]],
    ].each do |values, expected|
      describe "on #{values}" do
        let(:set) { S[*values] }

        it "preserves the original" do
          set.flatten
          set.should eql(S[*values])
        end

        it "returns the inlined values" do
          set.flatten.should eql(S[*expected])
        end
      end
    end

    context "on an empty set" do
      it "returns an empty set" do
        S.empty.flatten.should equal(S.empty)
      end
    end

    context "on a set with multiple levels of nesting" do
      it "inlines lower levels of nesting" do
        set = S[S[S[1]], S[S[2]]]
        set.flatten.should eql(S[1, 2])
      end
    end

    context "from a subclass" do
      it "returns an instance of the subclass" do
        subclass = Class.new(Hamster::Set)
        subclass.new.flatten.class.should be(subclass)
        subclass.new([S[1], S[2]]).flatten.class.should be(subclass)
      end
    end
  end
end