require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#delete" do
    it "removes elements that are #== to the argument" do
      V[1,2,3].delete(1).should eql(V[2,3])
      V[1,2,3].delete(2).should eql(V[1,3])
      V[1,2,3].delete(3).should eql(V[1,2])
      V[1,2,3].delete(0).should eql(V[1,2,3])
      V['a','b','a','c','a','a','d'].delete('a').should eql(V['b','c','d'])

      V[EqualNotEql.new, EqualNotEql.new].delete(:something).should eql(V.empty)
      V[EqlNotEqual.new, EqlNotEqual.new].delete(:something).should_not be_empty
    end

    context "on an empty vector" do
      it "returns self" do
        V.empty.delete(1).should be(V.empty)
      end
    end

    context "on a subclass of Vector" do
      it "returns an instance of the subclass" do
        subclass = Class.new(Hamster::Vector)
        instance = subclass.new([1,2,3])
        instance.delete(1).class.should be(subclass)
      end
    end
  end
end