require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  describe "#values_at" do
    context "on Hash without default proc" do
      let(:hash) { H[:a => 9, :b => 'a', :c => -10, :d => nil] }

      it "returns an empty vector when no keys are given" do
        hash.values_at.should be_kind_of(Hamster::Vector)
        hash.values_at.should eql(V.empty)
      end

      it "returns a vector of values for the given keys" do
        hash.values_at(:a, :d, :b).should be_kind_of(Hamster::Vector)
        hash.values_at(:a, :d, :b).should eql(V[9, nil, 'a'])
      end

      it "fills nil when keys are missing" do
        hash.values_at(:x, :a, :y, :b).should be_kind_of(Hamster::Vector)
        hash.values_at(:x, :a, :y, :b).should eql(V[nil, 9, nil, 'a'])
      end
    end

    context "on Hash with default proc" do
      let(:hash) { Hamster::Hash.new(:a => 9) { |key| "#{key}-VAL" } }

      it "fills the result of the default proc when keys are missing" do
        hash.values_at(:x, :a, :y).should be_kind_of(Hamster::Vector)
        hash.values_at(:x, :a, :y).should eql(V['x-VAL', 9, 'y-VAL'])
      end
    end
  end
end
