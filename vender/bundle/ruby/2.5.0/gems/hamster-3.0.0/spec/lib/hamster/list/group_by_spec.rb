require "spec_helper"
require "hamster/list"

describe Hamster::List do
  [:group_by, :group].each do |method|
    describe "##{method}" do
      context "on a really big list" do
        it "doesn't run out of stack" do
          -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).send(method) }.should_not raise_error
        end
      end

      context "with a block" do
        [
          [[], []],
          [[1], [true => L[1]]],
          [[1, 2, 3, 4], [true => L[3, 1], false => L[4, 2]]],
        ].each do |values, expected|
          context "on #{values.inspect}" do
            it "returns #{expected.inspect}" do
              L[*values].send(method, &:odd?).should eql(H[*expected])
            end
          end
        end
      end

      context "without a block" do
        [
          [[], []],
          [[1], [1 => L[1]]],
          [[1, 2, 3, 4], [1 => L[1], 2 => L[2], 3 => L[3], 4 => L[4]]],
        ].each do |values, expected|
          context "on #{values.inspect}" do
            it "returns #{expected.inspect}" do
              L[*values].send(method).should eql(H[*expected])
            end
          end
        end
      end
    end
  end
end