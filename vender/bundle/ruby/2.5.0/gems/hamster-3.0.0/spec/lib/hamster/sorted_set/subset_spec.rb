require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#subset?" do
    [
      [[], [], true],
      [["A"], [], false],
      [[], ["A"], true],
      [["A"], ["A"], true],
      [%w[A B C], ["B"], false],
      [["B"], %w[A B C], true],
      [%w[A B C], %w[A C], false],
      [%w[A C], %w[A B C], true],
      [%w[A B C], %w[A B C], true],
      [%w[A B C], %w[A B C D], true],
      [%w[A B C D], %w[A B C], false],
    ].each do |a, b, expected|
      context "for #{a.inspect} and #{b.inspect}" do
        it "returns #{expected}"  do
          SS[*a].subset?(SS[*b]).should == expected
        end
      end
    end
  end

  describe "#proper_subset?" do
    [
      [[], [], false],
      [["A"], [], false],
      [[], ["A"], true],
      [["A"], ["A"], false],
      [%w[A B C], ["B"], false],
      [["B"], %w[A B C], true],
      [%w[A B C], %w[A C], false],
      [%w[A C], %w[A B C], true],
      [%w[A B C], %w[A B C], false],
      [%w[A B C], %w[A B C D], true],
      [%w[A B C D], %w[A B C], false],
    ].each do |a, b, expected|
      context "for #{a.inspect} and #{b.inspect}" do
        it "returns #{expected}"  do
          SS[*a].proper_subset?(SS[*b]).should == expected
        end
      end
    end
  end
end