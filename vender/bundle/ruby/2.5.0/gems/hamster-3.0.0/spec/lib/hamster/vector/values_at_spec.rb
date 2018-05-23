require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#values_at" do
    let(:vector) { V['a', 'b', 'c'] }

    it "accepts any number of indices, and returns a vector of items at those indices" do
      vector.values_at(0).should eql(V['a'])
      vector.values_at(1,2).should eql(V['b', 'c'])
    end

    context "when passed invalid indices" do
      it "fills in with nils" do
        vector.values_at(1,2,3).should  eql(V['b', 'c', nil])
        vector.values_at(-10,10).should eql(V[nil, nil])
      end
    end

    context "when passed no arguments" do
      it "returns an empty vector" do
        vector.values_at.should eql(V.empty)
      end
    end

    context "from a subclass" do
      it "returns an instance of the subclass" do
        subclass = Class.new(Hamster::Vector)
        instance = subclass.new([1,2,3])
        instance.values_at(1,2).class.should be(subclass)
      end
    end
  end
end