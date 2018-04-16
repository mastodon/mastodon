require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#sum" do
    [
      [[], 0],
      [[2], 2],
      [[1, 3, 5, 7, 11], 27],
    ].each do |values, expected|
      describe "on #{values.inspect}" do
        it "returns #{expected.inspect}" do
          V[*values].sum.should == expected
        end
      end
    end
  end
end