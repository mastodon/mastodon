require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  describe "#partition" do
    [
      [[], [], []],
      [[1], [1], []],
      [[1, 2], [1], [2]],
      [[1, 2, 3], [1, 3], [2]],
      [[1, 2, 3, 4], [1, 3], [2, 4]],
      [[2, 3, 4], [3], [2, 4]],
      [[3, 4], [3], [4]],
      [[4], [], [4]],
    ].each do |values, expected_matches, expected_remainder|
      context "on #{values.inspect}" do
        let(:set) { S[*values] }

        context "with a block" do
          let(:result)  { set.partition(&:odd?) }
          let(:matches) { result.first }
          let(:remainder) { result.last }

          it "preserves the original" do
            result
            set.should eql(S[*values])
          end

          it "returns a frozen array with two items" do
            result.class.should be(Array)
            result.should be_frozen
            result.size.should be(2)
          end

          it "correctly identifies the matches" do
            matches.should eql(S[*expected_matches])
          end

          it "correctly identifies the remainder" do
            remainder.should eql(S[*expected_remainder])
          end
        end

        describe "without a block" do
          it "returns an Enumerator" do
            set.partition.class.should be(Enumerator)
            set.partition.each(&:odd?).should eql([S.new(expected_matches), S.new(expected_remainder)])
          end
        end
      end
    end
  end
end