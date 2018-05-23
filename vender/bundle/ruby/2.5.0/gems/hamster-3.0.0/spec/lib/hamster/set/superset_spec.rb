require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  [:superset?, :>=].each do |method|
    describe "##{method}" do
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
        describe "for #{a.inspect} and #{b.inspect}" do
          it "returns #{expected}"  do
            S[*a].send(method, S[*b]).should == expected
          end
        end
      end
    end
  end

  [:proper_superset?, :>].each do |method|
    describe "##{method}" do
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
        describe "for #{a.inspect} and #{b.inspect}" do
          it "returns #{expected}"  do
            S[*a].send(method, S[*b]).should == expected
          end
        end
      end
    end
  end
end