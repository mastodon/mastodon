require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#sample" do
    let(:list) { (1..10).to_list }

    it "returns a randomly chosen item" do
      chosen = 100.times.map { list.sample }
      chosen.each { |item| list.include?(item).should == true }
      list.each { |item| chosen.include?(item).should == true }
    end
  end
end