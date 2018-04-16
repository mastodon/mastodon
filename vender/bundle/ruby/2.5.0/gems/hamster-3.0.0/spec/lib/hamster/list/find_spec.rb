require "spec_helper"
require "hamster/list"

describe Hamster::List do
  [:find, :detect].each do |method|
    describe "##{method}" do
      context "on a really big list" do
        it "doesn't run out of stack" do
          -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).send(method) { false } }.should_not raise_error
        end
      end

      [
        [[], "A", nil],
        [[], nil, nil],
        [["A"], "A", "A"],
        [["A"], "B", nil],
        [["A"], nil, nil],
        [["A", "B", nil], "A", "A"],
        [["A", "B", nil], "B", "B"],
        [["A", "B", nil], nil, nil],
        [["A", "B", nil], "C", nil],
      ].each do |values, item, expected|
        context "on #{values.inspect}" do
          let(:list) { L[*values] }

          context "with a block" do
            it "returns #{expected.inspect}" do
              list.send(method) { |x| x == item }.should == expected
            end
          end

          context "without a block" do
            it "returns an Enumerator" do
              list.send(method).class.should be(Enumerator)
              list.send(method).each { |x| x == item }.should == expected
            end
          end
        end
      end
    end
  end
end