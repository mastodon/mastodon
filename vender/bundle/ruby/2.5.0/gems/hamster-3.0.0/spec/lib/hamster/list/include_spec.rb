require "spec_helper"
require "hamster/list"

describe Hamster::List do
  [:include?, :member?].each do |method|
    describe "##{method}" do
      context "on a really big list" do
        it "doesn't run out of stack" do
          -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).send(method, nil) }.should_not raise_error
        end
      end

      [
        [[], "A", false],
        [[], nil, false],
        [["A"], "A", true],
        [["A"], "B", false],
        [["A"], nil, false],
        [["A", "B", nil], "A", true],
        [["A", "B", nil], "B", true],
        [["A", "B", nil], nil, true],
        [["A", "B", nil], "C", false],
        [[2], 2, true],
        [[2], 2.0, true],
        [[2.0], 2.0, true],
        [[2.0], 2, true],
      ].each do |values, item, expected|
        context "on #{values.inspect}" do
          it "returns #{expected.inspect}" do
            L[*values].send(method, item).should == expected
          end
        end
      end
    end
  end
end