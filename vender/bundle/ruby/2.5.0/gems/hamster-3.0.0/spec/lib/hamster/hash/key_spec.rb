require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  describe "#key" do
    let(:hash) { H[a: 1, b: 1, c: 2, d: 3] }

    it "returns a key associated with the given value, if there is one" do
      [:a, :b].include?(hash.key(1)).should == true
      hash.key(2).should be(:c)
      hash.key(3).should be(:d)
    end

    it "returns nil if there is no key associated with the given value" do
      hash.key(5).should be_nil
      hash.key(0).should be_nil
    end

    it "uses #== to compare values for equality" do
      hash.key(EqualNotEql.new).should_not be_nil
      hash.key(EqlNotEqual.new).should be_nil
    end

    it "doesn't use default block if value is not found" do
      H.new(a: 1) { fail }.key(2).should be_nil
    end
  end
end