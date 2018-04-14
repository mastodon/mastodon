require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#unshift" do
    [
      [[], "A", ["A"]],
      [["A"], "B", %w[B A]],
      [["A"], "A", %w[A A]],
      [%w[A B C], "D", %w[D A B C]],
      [1..31, 0, 0..31],
      [1..32, 0, 0..32],
      [1..33, 0, 0..33]
    ].each do |values, new_value, expected|
      context "on #{values.inspect} with #{new_value.inspect}" do
        let(:vector) { V[*values] }

        it "preserves the original" do
          vector.unshift(new_value)
          vector.should eql(V[*values])
        end

        it "returns #{expected.inspect}" do
          vector.unshift(new_value).should eql(V[*expected])
        end
      end
    end
  end
end