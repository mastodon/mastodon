require "spec_helper"
require "hamster/deque"

describe Hamster::Deque do
  describe "#unshift" do
    [
      [[], "A", ["A"]],
      [["A"], "B", %w[B A]],
      [["A"], "A", %w[A A]],
      [%w[A B C], "D", %w[D A B C]],
    ].each do |values, new_value, expected|
      context "on #{values.inspect} with #{new_value.inspect}" do
        let(:deque) { D[*values] }

        it "preserves the original" do
          deque.unshift(new_value)
          deque.should eql(D[*values])
        end

        it "returns #{expected.inspect}" do
          deque.unshift(new_value).should eql(D[*expected])
        end


        it "returns a frozen instance" do
          deque.unshift(new_value).should be_frozen
        end
      end
    end
  end
end