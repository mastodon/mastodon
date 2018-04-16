require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#count" do
    it "returns the number of elements" do
      V[:a, :b, :c].count.should == 3
    end

    it "returns the number of elements that equal the argument" do
      V[:a, :b, :b, :c].count(:b).should == 2
    end

    it "returns the number of element for which the block evaluates to true" do
      V[:a, :b, :c].count { |s| s != :b }.should == 2
    end
  end
end