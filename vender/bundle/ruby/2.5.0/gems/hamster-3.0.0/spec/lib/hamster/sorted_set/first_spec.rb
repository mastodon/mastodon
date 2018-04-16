require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#first" do
    [
      [[], nil],
      [["A"], "A"],
      [%w[A B C], "A"],
      [%w[Z Y X], "X"]
    ].each do |values, expected|
      context "on #{values.inspect}" do
        it "returns #{expected.inspect}" do
          SS[*values].first.should eql(expected)
        end
      end
    end
  end
end