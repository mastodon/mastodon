require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
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
      describe "on #{values.inspect}" do
        let(:vector) { V[*values] }

        describe "with a block" do
          let(:result)    { vector.partition(&:odd?) }
          let(:matches)   { result.first }
          let(:remainder) { result.last }

          it "preserves the original" do
            result
            vector.should eql(V[*values])
          end

          it "returns a frozen array with two items" do
            result.class.should be(Array)
            result.should be_frozen
            result.size.should be(2)
          end

          it "correctly identifies the matches" do
            matches.should eql(V[*expected_matches])
          end

          it "correctly identifies the remainder" do
            remainder.should eql(V[*expected_remainder])
          end
        end

        describe "without a block" do
          it "returns an Enumerator" do
            vector.partition.class.should be(Enumerator)
            vector.partition.each(&:odd?).should eql([V.new(expected_matches), V.new(expected_remainder)])
          end
        end
      end
    end
  end
end