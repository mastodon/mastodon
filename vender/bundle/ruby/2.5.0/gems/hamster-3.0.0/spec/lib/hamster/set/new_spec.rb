require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  describe ".new" do
    it "initializes a new set" do
      set = S.new([1,2,3])
      set.size.should be(3)
      [1,2,3].each { |n| set.include?(n).should == true }
    end

    it "accepts a Range" do
      set = S.new(1..3)
      set.size.should be(3)
      [1,2,3].each { |n| set.include?(n).should == true }
    end

    it "returns a Set which doesn't change even if the initializer is mutated" do
      array = [1,2,3]
      set = S.new([1,2,3])
      array.push('BAD')
      set.should eql(S[1,2,3])
    end

    context "from a subclass" do
      it "returns a frozen instance of the subclass" do
        subclass = Class.new(Hamster::Set)
        instance = subclass.new(["some", "values"])
        instance.class.should be subclass
        instance.should be_frozen
      end
    end

    it "is amenable to overriding of #initialize" do
      class SnazzySet < Hamster::Set
        def initialize
          super(['SNAZZY!!!'])
        end
      end

      set = SnazzySet.new
      set.size.should be(1)
      set.include?('SNAZZY!!!').should == true
    end
  end

  describe "[]" do
    it "accepts any number of arguments and initializes a new set" do
      set = S[1,2,3,4]
      set.size.should be(4)
      [1,2,3,4].each { |n| set.include?(n).should == true }
    end
  end
end