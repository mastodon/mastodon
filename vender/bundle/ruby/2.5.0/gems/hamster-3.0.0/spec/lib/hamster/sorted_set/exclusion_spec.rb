require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  [:exclusion, :^].each do |method|
    describe "##{method}" do
      [
        [[], [], []],
        [["A"], [], ["A"]],
        [["A"], ["A"], []],
        [%w[A B C], ["B"], %w[A C]],
        [%w[A B C], %w[B C D], %w[A D]],
        [%w[A B C], %w[D E F], %w[A B C D E F]],
      ].each do |a, b, expected|
        context "for #{a.inspect} and #{b.inspect}" do
          it "returns #{expected.inspect}"  do
            SS[*a].send(method, SS[*b]).should eql(SS[*expected])
          end
        end
      end
    end
  end
end