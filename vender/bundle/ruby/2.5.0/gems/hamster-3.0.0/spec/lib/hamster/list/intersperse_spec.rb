require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#intersperse" do
    it "is lazy" do
      -> { Hamster.stream { fail }.intersperse("") }.should_not raise_error
    end

    [
      [[], []],
      [["A"], ["A"]],
      [%w[A B C], ["A", "|", "B", "|", "C"]]
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:list) { L[*values] }

        it "preserves the original" do
          list.intersperse("|")
          list.should eql(L[*values])
        end

        it "returns #{expected.inspect}" do
          list.intersperse("|").should eql(L[*expected])
        end
      end
    end
  end
end