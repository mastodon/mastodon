require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#compact" do
    it "returns a new Vector with all nils removed" do
      V[1, nil, 2, nil].compact.should eql(V[1, 2])
      V[1, 2, 3].compact.should eql(V[1, 2, 3])
      V[nil].compact.should eql(V.empty)
    end

    context "on an empty vector" do
      it "returns self" do
        V.empty.compact.should be(V.empty)
      end
    end

    it "doesn't remove false" do
      V[false].compact.should eql(V[false])
    end

    context "from a subclass" do
      it "returns an instance of the subclass" do
        subclass = Class.new(V)
        instance = subclass[1, nil, 2]
        instance.compact.class.should be(subclass)
      end
    end
  end
end