require "spec_helper"
require "hamster/list"

describe Hamster::List do
  [:union, :|].each do |method|
    describe "##{method}" do
      it "is lazy" do
        -> { Hamster.stream { fail }.union(Hamster.stream { fail }) }.should_not raise_error
      end

      [
        [[], [], []],
        [["A"], [], ["A"]],
        [%w[A B C], [], %w[A B C]],
        [%w[A A], ["A"], ["A"]],
      ].each do |a, b, expected|
        context "returns #{expected.inspect}" do
          let(:list_a) { L[*a] }
          let(:list_b) { L[*b] }

          it "for #{a.inspect} and #{b.inspect}"  do
            list_a.send(method, list_b).should eql(L[*expected])
          end

          it "for #{b.inspect} and #{a.inspect}"  do
            list_b.send(method, list_a).should eql(L[*expected])
          end
        end
      end
    end
  end
end