require "spec_helper"
require "hamster/list"

describe Hamster::List do
  [:find_index, :index].each do |method|
    describe "##{method}" do
      context "on a really big list" do
        it "doesn't run out of stack" do
          -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).send(method) { |item| false } }.should_not raise_error
        end
      end

      [
        [[], "A", nil],
        [[], nil, nil],
        [["A"], "A", 0],
        [["A"], "B", nil],
        [["A"], nil, nil],
        [["A", "B", nil], "A", 0],
        [["A", "B", nil], "B", 1],
        [["A", "B", nil], nil, 2],
        [["A", "B", nil], "C", nil],
        [[2], 2, 0],
        [[2], 2.0, 0],
        [[2.0], 2.0, 0],
        [[2.0], 2, 0],
      ].each do |values, item, expected|
        context "looking for #{item.inspect} in #{values.inspect}" do
          it "returns #{expected.inspect}" do
            L[*values].send(method) { |x| x == item }.should == expected
          end
        end
      end
    end
  end
end