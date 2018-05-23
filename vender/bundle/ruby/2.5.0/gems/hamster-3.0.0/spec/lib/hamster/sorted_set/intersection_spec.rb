require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  [:intersection, :&].each do |method|
    describe "##{method}" do
      [
        [[], [], []],
        [["A"], [], []],
        [["A"], ["A"], ["A"]],
        [%w[A B C], ["B"], ["B"]],
        [%w[A B C], %w[A C], %w[A C]],
        [%w[A M T X], %w[B C D E F G H I M P Q T U], %w[M T]]
      ].each do |a, b, expected|
        context "for #{a.inspect} and #{b.inspect}" do
          it "returns #{expected.inspect}" do
            SS[*a].send(method, SS[*b]).should eql(SS[*expected])
          end
        end

        context "for #{b.inspect} and #{a.inspect}" do
          it "returns #{expected.inspect}" do
            SS[*b].send(method, SS[*a]).should eql(SS[*expected])
          end
        end
      end
    end
  end
end