require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  describe ".new" do
    it "is amenable to overriding of #initialize" do
      class SnazzyHash < Hamster::Hash
        def initialize
          super({'snazzy?' => 'oh yeah'})
        end
      end

      SnazzyHash.new['snazzy?'].should == 'oh yeah'
    end

    context "from a subclass" do
      it "returns a frozen instance of the subclass" do
        subclass = Class.new(Hamster::Hash)
        instance = subclass.new("some" => "values")
        instance.class.should be(subclass)
        instance.frozen?.should be true
      end
    end

    it "accepts an array as initializer" do
      H.new([['a', 'b'], ['c', 'd']]).should eql(H['a' => 'b', 'c' => 'd'])
    end

    it "returns a Hash which doesn't change even if initializer is mutated" do
      rbhash = {a: 1, b: 2}
      hash = H.new(rbhash)
      rbhash[:a] = 'BAD'
      hash.should eql(H[a: 1, b: 2])
    end
  end

  describe ".[]" do
    it "accepts a Ruby Hash as initializer" do
      hash = H[a: 1, b: 2]
      hash.class.should be(Hamster::Hash)
      hash.size.should == 2
      hash.key?(:a).should == true
      hash.key?(:b).should == true
    end

    it "accepts a Hamster::Hash as initializer" do
      hash = H[H.new(a: 1, b: 2)]
      hash.class.should be(Hamster::Hash)
      hash.size.should == 2
      hash.key?(:a).should == true
      hash.key?(:b).should == true
    end

    it "accepts an array as initializer" do
      hash = H[[[:a, 1], [:b, 2]]]
      hash.class.should be(Hamster::Hash)
      hash.size.should == 2
      hash.key?(:a).should == true
      hash.key?(:b).should == true
    end

    it "can be used with a subclass of Hamster::Hash" do
      subclass = Class.new(Hamster::Hash)
      instance = subclass[a: 1, b: 2]
      instance.class.should be(subclass)
      instance.size.should == 2
      instance.key?(:a).should == true
      instance.key?(:b).should == true
    end
  end
end