require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#take_while" do
    [
      [[], []],
      [["A"], ["A"]],
      [%w[A B C], %w[A B]]
    ].each do |values, expected|
      describe "on #{values.inspect}" do
        let(:vector) { V[*values] }
        let(:result) { vector.take_while { |item| item < "C" }}

        describe "with a block" do
          it "returns #{expected.inspect}" do
            result.should eql(V[*expected])
          end

          it "preserves the original" do
            result
            vector.should eql(V[*values])
          end
        end

        describe "without a block" do
          it "returns an Enumerator" do
            vector.take_while.class.should be(Enumerator)
            vector.take_while.each { |item| item < "C" }.should eql(V[*expected])
          end
        end
      end
    end
  end
end
