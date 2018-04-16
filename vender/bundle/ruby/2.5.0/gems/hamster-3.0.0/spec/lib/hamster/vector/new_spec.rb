require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe ".new" do
    it "accepts a single enumerable argument and creates a new vector" do
      vector = Hamster::Vector.new([1,2,3])
      vector.size.should be(3)
      vector[0].should be(1)
      vector[1].should be(2)
      vector[2].should be(3)
    end

    it "makes a defensive copy of a non-frozen mutable Array passed in" do
      array = [1,2,3]
      vector = Hamster::Vector.new(array)
      array[0] = 'changed'
      vector[0].should be(1)
    end

    it "is amenable to overriding of #initialize" do
      class SnazzyVector < Hamster::Vector
        def initialize
          super(['SNAZZY!!!'])
        end
      end

      vector = SnazzyVector.new
      vector.size.should be(1)
      vector.should == ['SNAZZY!!!']
    end

    context "from a subclass" do
      it "returns a frozen instance of the subclass" do
        subclass = Class.new(Hamster::Vector)
        instance = subclass.new(["some", "values"])
        instance.class.should be subclass
        instance.frozen?.should be true
      end
    end
  end

  describe ".[]" do
    it "accepts a variable number of items and creates a new vector" do
      vector = Hamster::Vector['a', 'b']
      vector.size.should be(2)
      vector[0].should == 'a'
      vector[1].should == 'b'
    end
  end
end