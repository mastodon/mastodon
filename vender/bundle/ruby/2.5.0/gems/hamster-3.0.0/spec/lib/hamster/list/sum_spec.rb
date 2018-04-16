require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#sum" do
    context "on a really big list" do
      it "doesn't run out of stack" do
        -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).sum }.should_not raise_error
      end
    end

    [
      [[], 0],
      [[2], 2],
      [[1, 3, 5, 7, 11], 27],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        it "returns #{expected.inspect}" do
          L[*values].sum.should == expected
        end
      end
    end
  end
end