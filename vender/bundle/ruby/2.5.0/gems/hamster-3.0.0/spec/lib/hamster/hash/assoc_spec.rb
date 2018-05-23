require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  let(:hash) { H[a: 3, b: 2, c: 1] }

  describe "#assoc" do
    it "searches for a key/val pair with a given key" do
      hash.assoc(:a).should == [:a, 3]
      hash.assoc(:b).should == [:b, 2]
      hash.assoc(:c).should == [:c, 1]
    end

    it "returns nil if a matching key is not found" do
      hash.assoc(:d).should be_nil
      hash.assoc(nil).should be_nil
      hash.assoc(0).should be_nil
    end

    it "returns nil even if there is a default" do
      H.new(a: 1, b: 2) { fail }.assoc(:c).should be_nil
    end

    it "uses #== to compare keys with provided object" do
      hash.assoc(EqualNotEql.new).should_not be_nil
      hash.assoc(EqlNotEqual.new).should be_nil
    end
  end

  describe "#rassoc" do
    it "searches for a key/val pair with a given value" do
      hash.rassoc(1).should == [:c, 1]
      hash.rassoc(2).should == [:b, 2]
      hash.rassoc(3).should == [:a, 3]
    end

    it "returns nil if a matching value is not found" do
      hash.rassoc(0).should be_nil
      hash.rassoc(4).should be_nil
      hash.rassoc(nil).should be_nil
    end

    it "returns nil even if there is a default" do
      H.new(a: 1, b: 2) { fail }.rassoc(3).should be_nil
    end

    it "uses #== to compare values with provided object" do
      hash.rassoc(EqualNotEql.new).should_not be_nil
      hash.rassoc(EqlNotEqual.new).should be_nil
    end
  end
end