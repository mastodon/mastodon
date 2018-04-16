require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#at" do
    context "on a really big list" do
      let(:list) { Hamster.interval(0, STACK_OVERFLOW_DEPTH) }

      it "doesn't run out of stack" do
        -> { list.at(STACK_OVERFLOW_DEPTH) }.should_not raise_error
      end
    end

    [
      [[], 10, nil],
      [["A"], 10, nil],
      [%w[A B C], 0, "A"],
      [%w[A B C], 2, "C"],
      [%w[A B C], -1, "C"],
      [%w[A B C], -2, "B"],
      [%w[A B C], -4, nil]
    ].each do |values, number, expected|
      describe "#{values.inspect} with #{number}" do
        it "returns #{expected.inspect}" do
          L[*values].at(number).should == expected
        end
      end
    end
  end
end