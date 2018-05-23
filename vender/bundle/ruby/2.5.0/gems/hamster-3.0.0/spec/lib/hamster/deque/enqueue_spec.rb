require "spec_helper"
require "hamster/deque"

describe Hamster::Deque do
  [:enqueue, :push].each do |method|
    describe "##{method}" do
      [
        [[], "A", ["A"]],
        [["A"], "B", %w[A B]],
        [["A"], "A", %w[A A]],
        [%w[A B C], "D", %w[A B C D]],
      ].each do |values, new_value, expected|
        describe "on #{values.inspect} with #{new_value.inspect}" do
          let(:deque) { D[*values] }

          it "preserves the original" do
            deque.send(method, new_value)
            deque.should eql(D[*values])
          end

          it "returns #{expected.inspect}" do
            deque.send(method, new_value).should eql(D[*expected])
          end
        end
      end
    end
  end
end