require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  describe "#sample" do
    let(:set) { S.new(1..10) }

    it "returns a randomly chosen item" do
      chosen = 100.times.map { set.sample }
      chosen.each { |item| set.include?(item).should == true }
      set.each { |item| chosen.include?(item).should == true }
    end
  end
end
