require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#split_at" do
    it "is lazy" do
      -> { Hamster.stream { fail }.split_at(1) }.should_not raise_error
    end

    [
      [[], [], []],
      [[1], [1], []],
      [[1, 2], [1, 2], []],
      [[1, 2, 3], [1, 2], [3]],
      [[1, 2, 3, 4], [1, 2], [3, 4]],
    ].each do |values, expected_prefix, expected_remainder|
      context "on #{values.inspect}" do
        let(:list) { L[*values] }
        let(:result) { list.split_at(2) }
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

        it "correctly identifies the matches" do
          prefix.should eql(L[*expected_prefix])
        end

        it "correctly identifies the remainder" do
          remainder.should eql(L[*expected_remainder])
        end
      end
    end
  end
end