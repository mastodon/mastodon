require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#drop_while" do
    [
      [[], []],
      [["A"], []],
      [%w[A B C], ["C"]],
      [%w[A B C D E F G], %w[C D E F G]]
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:sorted_set) { SS[*values] }

        context "with a block" do
          it "preserves the original" do
            sorted_set.drop_while { |item| item < "C" }
            sorted_set.should eql(SS[*values])
          end

          it "returns #{expected.inspect}" do
            sorted_set.drop_while { |item| item < "C" }.should eql(SS[*expected])
          end
        end

        context "without a block" do
          it "returns an Enumerator" do
            sorted_set.drop_while.class.should be(Enumerator)
            sorted_set.drop_while.each { |item| item < "C" }.should eql(SS[*expected])
          end
        end
      end
    end
  end
end