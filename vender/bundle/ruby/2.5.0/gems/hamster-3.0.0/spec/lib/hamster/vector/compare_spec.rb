require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#<=>" do
    [
      [[], [1]],
      [[1], [2]],
      [[1], [1, 2]],
      [[2, 3, 4], [3, 4, 5]],
      [[[0]], [[1]]]
    ].each do |items1, items2|
      describe "with #{items1} and #{items2}" do
        it "returns -1" do
          (V.new(items1) <=> V.new(items2)).should be(-1)
        end
      end

      describe "with #{items2} and #{items1}" do
        it "returns 1" do
          (V.new(items2) <=> V.new(items1)).should be(1)
        end
      end

      describe "with #{items1} and #{items1}" do
        it "returns 0" do
          (V.new(items1) <=> V.new(items1)).should be(0)
        end
      end
    end
  end
end