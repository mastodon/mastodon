require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  describe "#first" do
    context "on an empty set" do
      it "returns nil" do
        S.empty.first.should be_nil
      end
    end

    context "on a non-empty set" do
      it "returns an arbitrary value from the set" do
        %w[A B C].include?(S["A", "B", "C"].first).should == true
      end
    end

    it "returns nil if only member of set is nil" do
      S[nil].first.should be(nil)
    end

    it "returns the first item yielded by #each" do
      10.times do
        set = S.new((rand(10)+1).times.collect { rand(10000 )})
        set.each { |item| break item }.should be(set.first)
      end
    end
  end
end