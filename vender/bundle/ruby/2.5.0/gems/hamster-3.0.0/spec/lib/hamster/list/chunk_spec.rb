require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#chunk" do
    it "is lazy" do
      -> { Hamster.stream { fail }.chunk(2) }.should_not raise_error
    end

    [
      [[], []],
      [["A"], [L["A"]]],
      [%w[A B C], [L["A", "B"], L["C"]]],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:list) { L[*values] }

        it "preserves the original" do
          list.chunk(2)
          list.should eql(L[*values])
        end

        it "returns #{expected.inspect}" do
          list.chunk(2).should eql(L[*expected])
        end
      end
    end
  end
end