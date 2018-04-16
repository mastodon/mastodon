require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#take_while" do
    [
      [[], []],
      [["A"], ["A"]],
      [%w[A B C], %w[A B]],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:sorted_set) { SS[*values] }

        context "with a block" do
          it "returns #{expected.inspect}" do
            sorted_set.take_while { |item| item < "C" }.should eql(SS[*expected])
          end

          it "preserves the original" do
            sorted_set.take_while { |item| item < "C" }
            sorted_set.should eql(SS[*values])
          end
        end

        context "without a block" do
          it "returns an Enumerator" do
            sorted_set.take_while.class.should be(Enumerator)
            sorted_set.take_while.each { |item| item < "C" }.should eql(SS[*expected])
          end
        end
      end
    end
  end
end
