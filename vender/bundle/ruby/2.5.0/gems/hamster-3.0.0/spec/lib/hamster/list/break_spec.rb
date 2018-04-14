require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#break" do
    it "is lazy" do
      -> { Hamster.stream { fail }.break { |item| false } }.should_not raise_error
    end

    [
      [[], [], []],
      [[1], [1], []],
      [[1, 2], [1, 2], []],
      [[1, 2, 3], [1, 2], [3]],
      [[1, 2, 3, 4], [1, 2], [3, 4]],
      [[2, 3, 4], [2], [3, 4]],
      [[3, 4], [], [3, 4]],
      [[4], [], [4]],
    ].each do |values, expected_prefix, expected_remainder|
      context "on #{values.inspect}" do
        let(:list) { L[*values] }

        context "with a block" do
          let(:result) { list.break { |item| item > 2 }}
          let(:prefix) { result.first }
          let(:remainder) { result.last }

          it "preserves the original" do
            result
            list.should eql(L[*values])
          end

          it "returns a frozen array with two items" do
            result.class.should be(Array)
            result.should be_frozen
            result.size.should be(2)
          end

          it "correctly identifies the prefix" do
            prefix.should eql(L[*expected_prefix])
          end

          it "correctly identifies the remainder" do
            remainder.should eql(L[*expected_remainder])
          end
        end

        context "without a block" do
          let(:result) { list.break }
          let(:prefix) { result.first }
          let(:remainder) { result.last }

          it "returns a frozen array with two items" do
            result.class.should be(Array)
            result.should be_frozen
            result.size.should be(2)
          end

          it "returns self as the prefix" do
            prefix.should equal(list)
          end

          it "leaves the remainder empty" do
            remainder.should be_empty
          end
        end
      end
    end
  end
end