require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  [:size, :length].each do |method|
    describe "##{method}" do
      [
        [[], 0],
        [["A"], 1],
        [%w[A B C], 3],
      ].each do |values, result|
        it "returns #{result} for #{values.inspect}" do
          SS[*values].send(method).should == result
        end
      end
    end
  end
end