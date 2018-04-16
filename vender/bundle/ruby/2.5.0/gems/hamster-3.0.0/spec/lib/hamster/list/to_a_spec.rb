require "spec_helper"
require "hamster/list"

describe Hamster::List do
  [:to_a, :entries].each do |method|
    describe "##{method}" do
      context "on a really big list" do
        it "doesn't run out of stack" do
          -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).to_a }.should_not raise_error
        end
      end

      [
        [],
        ["A"],
        %w[A B C],
      ].each do |values|
        context "on #{values.inspect}" do
          let(:list) { L[*values] }

          it "returns #{values.inspect}" do
            list.send(method).should == values
          end

          it "leaves the original unchanged" do
            list.send(method)
            list.should eql(L[*values])
          end

          it "returns a mutable array" do
            result = list.send(method)
            expect(result.last).to_not eq("The End")
            result << "The End"
            result.last.should == "The End"
          end
        end
      end
    end
  end
end