require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  let(:vector) { V[[:a, 3], [:b, 2], [:c, 1]] }

  describe "#assoc" do
    it "searches for a 2-element array with a given 1st item" do
      vector.assoc(:b).should == [:b, 2]
    end

    it "returns nil if a matching 1st item is not found" do
      vector.assoc(:d).should be_nil
    end

    it "uses #== to compare 1st items with provided object" do
      vector.assoc(EqualNotEql.new).should_not be_nil
      vector.assoc(EqlNotEqual.new).should be_nil
    end

    it "skips elements which are not indexable" do
      V[false, true, nil].assoc(:b).should be_nil
      V[[1,2], nil].assoc(3).should be_nil
    end
  end

  describe "#rassoc" do
    it "searches for a 2-element array with a given 2nd item" do
      vector.rassoc(1).should == [:c, 1]
    end

    it "returns nil if a matching 2nd item is not found" do
      vector.rassoc(4).should be_nil
    end

    it "uses #== to compare 2nd items with provided object" do
      vector.rassoc(EqualNotEql.new).should_not be_nil
      vector.rassoc(EqlNotEqual.new).should be_nil
    end

    it "skips elements which are not indexable" do
      V[false, true, nil].rassoc(:b).should be_nil
      V[[1,2], nil].rassoc(3).should be_nil
    end
  end
end