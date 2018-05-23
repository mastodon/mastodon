require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  describe "#fetch_values" do
    context "when the all the requests keys exist" do
      it "returns a vector of values for the given keys" do
        h = H[:a => 9, :b => 'a', :c => -10, :d => nil]
        h.fetch_values.should be_kind_of(Hamster::Vector)
        h.fetch_values.should eql(V.empty)
        h.fetch_values(:a, :d, :b).should be_kind_of(Hamster::Vector)
        h.fetch_values(:a, :d, :b).should eql(V[9, nil, 'a'])
      end
    end

    context "when the key does not exist" do
      it "raises a KeyError" do
        -> { H["A" => "aye", "C" => "Cee"].fetch_values("A", "B") }.should raise_error(KeyError)
      end
    end
  end
end
