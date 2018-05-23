require "spec_helper"
require "hamster/deque"

describe Hamster::Deque do
  [:to_a, :entries].each do |method|
    describe "##{method}" do
      [
        [],
        ["A"],
        %w[A B C],
      ].each do |values|
        context "on #{values.inspect}" do
          it "returns #{values.inspect}" do
            D[*values].send(method).should == values
          end

          it "returns a mutable array" do
            result = D[*values].send(method)
            expect(result.last).to_not eq("The End")
            result << "The End"
            result.last.should == "The End"
          end
        end
      end
    end
  end
end