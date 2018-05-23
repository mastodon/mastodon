require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#indices" do
    context "when called with a block" do
      it "is lazy" do
        count = 0
        Hamster.stream { count += 1 }.indices { |item| true }
        count.should <= 1
      end

      context "on a large list which doesn't contain desired item" do
        it "doesn't blow the stack" do
          -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).indices { |x| x < 0 }.size }.should_not raise_error
        end
      end

      [
        [[], "A", []],
        [["A"], "B", []],
        [%w[A B A], "B", [1]],
        [%w[A B A], "A", [0, 2]],
        [[2], 2, [0]],
        [[2], 2.0, [0]],
        [[2.0], 2.0, [0]],
        [[2.0], 2, [0]],
      ].each do |values, item, expected|
        context "looking for #{item.inspect} in #{values.inspect}" do
          it "returns #{expected.inspect}" do
            L[*values].indices { |x| x == item }.should eql(L[*expected])
          end
        end
      end
    end

    context "when called with a single argument" do
      it "is lazy" do
        count = 0
        Hamster.stream { count += 1 }.indices(nil)
        count.should <= 1
      end

      [
        [[], "A", []],
        [["A"], "B", []],
        [%w[A B A], "B", [1]],
        [%w[A B A], "A", [0, 2]],
        [[2], 2, [0]],
        [[2], 2.0, [0]],
        [[2.0], 2.0, [0]],
        [[2.0], 2, [0]],
      ].each do |values, item, expected|
        context "looking for #{item.inspect} in #{values.inspect}" do
          it "returns #{expected.inspect}" do
            L[*values].indices(item).should eql(L[*expected])
          end
        end
      end
    end
  end
end