require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#drop" do
    it "is lazy" do
      -> { Hamster.stream { fail }.drop(1) }.should_not raise_error
    end

    [
      [[], 10, []],
      [["A"], 10, []],
      [["A"], -1, ["A"]],
      [%w[A B C], 0, %w[A B C]],
      [%w[A B C], 2, ["C"]],
    ].each do |values, number, expected|
      context "with #{number} from #{values.inspect}" do
        let(:list) { L[*values] }

        it "preserves the original" do
          list.drop(number)
          list.should eql(L[*values])
        end

        it "returns #{expected.inspect}" do
          list.drop(number).should == L[*expected]
        end
      end
    end
  end
end