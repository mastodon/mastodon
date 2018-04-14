require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  describe "#invert" do
    let(:hash) { H[a: 3, b: 2, c: 1] }

    it "uses the existing keys as values and values as keys" do
      hash.invert.should eql(H[3 => :a, 2 => :b, 1 => :c])
    end

    it "will select one key/value pair among multiple which have same value" do
      [H[1 => :a],
       H[1 => :b],
       H[1 => :c]].include?(H[a: 1, b: 1, c: 1].invert).should == true
    end

    it "doesn't change the original Hash" do
      hash.invert
      hash.should eql(H[a: 3, b: 2, c: 1])
    end

    context "from a subclass of Hash" do
      it "returns an instance of the subclass" do
        subclass = Class.new(Hamster::Hash)
        instance = subclass.new(a: 1, b: 2)
        instance.invert.class.should be(subclass)
      end
    end
  end
end