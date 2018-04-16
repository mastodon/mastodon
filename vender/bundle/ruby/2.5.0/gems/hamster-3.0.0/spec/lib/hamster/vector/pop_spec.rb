require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#pop" do
    [
      [[], []],
      [["A"], []],
      [%w[A B C], %w[A B]],
      [1..32, 1..31],
      [1..33, 1..32]
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:vector) { V[*values] }

        it "preserves the original" do
          vector.pop
          vector.should eql(V[*values])
        end

        it "returns #{expected.inspect}" do
          vector.pop.should eql(V[*expected])
        end
      end
    end
  end
end