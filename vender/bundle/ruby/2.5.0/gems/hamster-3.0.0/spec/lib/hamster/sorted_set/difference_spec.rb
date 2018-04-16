require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  [:difference, :subtract, :-].each do |method|
    describe "##{method}" do
      [
        [[], [], []],
        [["A"], [], ["A"]],
        [["A"], ["A"], []],
        [%w[A B C], ["B"], %w[A C]],
        [%w[A B C], %w[A C], ["B"]],
        [%w[A B C D E F], %w[B E F G M X], %w[A C D]]
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