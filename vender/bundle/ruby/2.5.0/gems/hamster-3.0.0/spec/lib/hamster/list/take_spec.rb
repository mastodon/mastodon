require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#take" do
    it "is lazy" do
      -> { Hamster.stream { fail }.take(1) }.should_not raise_error
    end

    [
      [[], 10, []],
      [["A"], 10, ["A"]],
      [["A"], -1, []],
      [%w[A B C], 0, []],
      [%w[A B C], 2, %w[A B]],
    ].each do |values, number, expected|
      context "#{number} from #{values.inspect}" do
        let(:list) { L[*values] }

        it "preserves the original" do
          list.take(number)
          list.should eql(L[*values])
        end

        it "returns #{expected.inspect}" do
          list.take(number).should eql(L[*expected])
        end
      end
    end
  end
end