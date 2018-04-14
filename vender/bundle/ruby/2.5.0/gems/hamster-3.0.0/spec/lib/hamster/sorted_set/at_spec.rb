require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#at" do
    [
      [[], 10, nil],
      [["A"], 10, nil],
      [%w[A B C], 0, "A"],
      [%w[A B C], 1, "B"],
      [%w[A B C], 2, "C"],
      [%w[A B C], 3, nil],
      [%w[A B C], -1, "C"],
      [%w[A B C], -2, "B"],
      [%w[A B C], -3, "A"],
      [%w[A B C], -4, nil]
    ].each do |values, number, expected|
      describe "#{values.inspect} with #{number}" do
        it "returns #{expected.inspect}" do
          SS[*values].at(number).should == expected
        end
      end
    end
  end
end