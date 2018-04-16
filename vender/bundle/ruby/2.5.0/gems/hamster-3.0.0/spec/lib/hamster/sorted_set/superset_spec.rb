require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#superset?" do
    [
      [[], [], true],
      [["A"], [], true],
      [[], ["A"], false],
      [["A"], ["A"], true],
      [%w[A B C], ["B"], true],
      [["B"], %w[A B C], false],
      [%w[A B C], %w[A C], true],
      [%w[A C], %w[A B C], false],
      [%w[A B C], %w[A B C], true],
      [%w[A B C], %w[A B C D], false],
      [%w[A B C D], %w[A B C], true],
    ].each do |a, b, expected|
      context "for #{a.inspect} and #{b.inspect}" do
        it "returns #{expected}"  do
          SS[*a].superset?(SS[*b]).should == expected
        end
      end
    end
  end

  describe "#proper_superset?" do
    [
      [[], [], false],
      [["A"], [], true],
      [[], ["A"], false],
      [["A"], ["A"], false],
      [%w[A B C], ["B"], true],
      [["B"], %w[A B C], false],
      [%w[A B C], %w[A C], true],
      [%w[A C], %w[A B C], false],
      [%w[A B C], %w[A B C], false],
      [%w[A B C], %w[A B C D], false],
      [%w[A B C D], %w[A B C], true],
    ].each do |a, b, expected|
      context "for #{a.inspect} and #{b.inspect}" do
        it "returns #{expected}"  do
          SS[*a].proper_superset?(SS[*b]).should == expected
        end
      end
    end
  end
end