require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#delete" do
    it "removes elements that are #== to the argument" do
      L[1,2,3].delete(1).should eql(L[2,3])
      L[1,2,3].delete(2).should eql(L[1,3])
      L[1,2,3].delete(3).should eql(L[1,2])
      L[1,2,3].delete(0).should eql(L[1,2,3])
      L['a','b','a','c','a','a','d'].delete('a').should eql(L['b','c','d'])

      L[EqualNotEql.new, EqualNotEql.new].delete(:something).should eql(L[])
      L[EqlNotEqual.new, EqlNotEqual.new].delete(:something).should_not be_empty
    end
  end
end