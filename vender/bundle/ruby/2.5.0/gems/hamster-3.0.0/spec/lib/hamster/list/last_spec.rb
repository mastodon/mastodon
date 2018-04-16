require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#last" do
    context "on a really big list" do
      it "doesn't run out of stack" do
        -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).last }.should_not raise_error
      end
    end

    [
      [[], nil],
      [["A"], "A"],
      [%w[A B C], "C"],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        it "returns #{expected.inspect}" do
          L[*values].last.should == expected
        end
      end
    end
  end
end