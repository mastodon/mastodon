require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  [:include?, :member?].each do |method|
    describe "##{method}" do
      [
        [[], "A", false],
        [[], nil, false],
        [["A"], "A", true],
        [["A"], "B", false],
        [["A"], nil, false],
        [["A", "B", nil], "A", true],
        [["A", "B", nil], "B", true],
        [["A", "B", nil], nil, true],
        [["A", "B", nil], "C", false],
        [["A", "B", false], false, true],
        [[2], 2, true],
        [[2], 2.0, true],
        [[2.0], 2.0, true],
        [[2.0], 2, true],
      ].each do |values, item, expected|
        describe "on #{values.inspect}" do
          it "returns #{expected.inspect}" do
            V[*values].send(method, item).should == expected
          end
        end
      end
    end
  end
end