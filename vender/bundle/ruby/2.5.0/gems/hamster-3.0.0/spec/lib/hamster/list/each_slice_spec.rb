require "spec_helper"
require "hamster/list"

describe Hamster::List do
  [:each_chunk, :each_slice].each do |method|
    describe "##{method}" do
      context "on a really big list" do
        it "doesn't run out of stack" do
          -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).send(method, 1) { |item| } }.should_not raise_error
        end
      end

      [
        [[], []],
        [["A"], [L["A"]]],
        [%w[A B C], [L["A", "B"], L["C"]]],
      ].each do |values, expected|
        context "on #{values.inspect}" do
          let(:list) { L[*values] }

          context "with a block" do
            it "preserves the original" do
              list.should eql(L[*values])
            end

            it "iterates over the items in order" do
              yielded = []
              list.send(method, 2) { |item| yielded << item }
              yielded.should eql(expected)
            end

            it "returns self" do
              list.send(method, 2) { |item| item }.should be(list)
            end
          end

          context "without a block" do
            it "preserves the original" do
              list.send(method, 2)
              list.should eql(L[*values])
            end

            it "returns an Enumerator" do
              list.send(method, 2).class.should be(Enumerator)
              list.send(method, 2).to_a.should eql(expected)
            end
          end
        end
      end
    end
  end
end