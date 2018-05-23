require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#disjoint?" do
    [
      [[], [], true],
      [["A"], [], true],
      [[], ["A"], true],
      [["A"], ["A"], false],
      [%w[A B C], ["B"], false],
      [["B"], %w[A B C], false],
      [%w[A B C], %w[D E], true],
      [%w[F G H I], %w[A B C], true],
      [%w[A B C], %w[A B C], false],
      [%w[A B C], %w[A B C D], false],
      [%w[D E F G], %w[A B C], true],
    ].each do |a, b, expected|
      context "for #{a.inspect} and #{b.inspect}" do
        it "returns #{expected}" do
          SS[*a].disjoint?(SS[*b]).should be(expected)
        end
      end
    end
  end
end