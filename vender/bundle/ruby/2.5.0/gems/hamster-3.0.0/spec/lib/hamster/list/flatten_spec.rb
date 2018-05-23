require "spec_helper"
require "hamster/list"

describe Hamster do
  describe "#flatten" do
    it "is lazy" do
      -> { Hamster.stream { fail }.flatten }.should_not raise_error
    end

    [
      [[], []],
      [["A"], ["A"]],
      [%w[A B C], %w[A B C]],
      [["A", L["B"], "C"], %w[A B C]],
      [[L["A"], L["B"], L["C"]], %w[A B C]],
    ].each do |values, expected|
      context "on #{values}" do
        let(:list) { L[*values] }

        it "preserves the original" do
          list.flatten
          list.should eql(L[*values])
        end

        it "returns an empty list" do
          list.flatten.should eql(L[*expected])
        end
      end
    end
  end
end