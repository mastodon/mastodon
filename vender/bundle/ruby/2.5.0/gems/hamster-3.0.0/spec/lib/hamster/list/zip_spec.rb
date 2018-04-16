require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#zip" do
    it "is lazy" do
      -> { Hamster.stream { fail }.zip(Hamster.stream { fail }) }.should_not raise_error
    end

    [
      [[], [], []],
      [["A"], ["aye"], [L["A", "aye"]]],
      [["A"], [], [L["A", nil]]],
      [[], ["A"], [L[nil, "A"]]],
      [%w[A B C], %w[aye bee see], [L["A", "aye"], L["B", "bee"], L["C", "see"]]],
    ].each do |left, right, expected|
      context "on #{left.inspect} and #{right.inspect}" do
        it "returns #{expected.inspect}" do
          L[*left].zip(L[*right]).should eql(L[*expected])
        end
      end
    end
  end
end
