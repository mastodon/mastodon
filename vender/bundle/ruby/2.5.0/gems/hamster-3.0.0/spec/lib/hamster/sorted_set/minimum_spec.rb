require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#min" do
    [
      [[], nil],
      [["A"], "A"],
      [%w[Ichi Ni San], "Ichi"],
      [[1,2,3,4,5], 1],
      [[0, -0.0, 2.2, -4, -4.2], -4.2],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        it "returns #{expected.inspect}" do
          SS[*values].min.should == expected
        end
      end
    end
  end
end