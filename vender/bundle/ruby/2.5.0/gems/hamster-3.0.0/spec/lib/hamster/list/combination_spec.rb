require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#combination" do
    it "is lazy" do
      -> { Hamster.stream { fail }.combination(2) }.should_not raise_error
    end

    [
      [%w[A B C D], 1, [L["A"], L["B"], L["C"], L["D"]]],
      [%w[A B C D], 2, [L["A","B"], L["A","C"], L["A","D"], L["B","C"], L["B","D"], L["C","D"]]],
      [%w[A B C D], 3, [L["A","B","C"], L["A","B","D"], L["A","C","D"], L["B","C","D"]]],
      [%w[A B C D], 4, [L["A", "B", "C", "D"]]],
      [%w[A B C D], 0, [EmptyList]],
      [%w[A B C D], 5, []],
      [[], 0, [EmptyList]],
      [[], 1, []],
    ].each do |values, number, expected|
      context "on #{values.inspect} in groups of #{number}" do
        let(:list) { L[*values] }

        it "preserves the original" do
          list.combination(number)
          list.should eql(L[*values])
        end

        it "returns #{expected.inspect}" do
          list.combination(number).should eql(L[*expected])
        end
      end
    end
  end
end