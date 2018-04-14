require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  let(:hash) { H["A" => "aye", "B" => "bee", "C" => "see"] }

  [:each, :each_pair].each do |method|
    describe "##{method}" do
      context "with a block (internal iteration)" do
        it "returns self" do
          hash.send(method) {}.should be(hash)
        end

        it "yields all key/value pairs" do
          actual_pairs = {}
          hash.send(method) { |key, value| actual_pairs[key] = value }
          actual_pairs.should == { "A" => "aye", "B" => "bee", "C" => "see" }
        end

        it "yields key/value pairs in the same order as #each_key and #each_value" do
          hash.each.to_a.should eql(hash.each_key.zip(hash.each_value))
        end

        it "yields both of a pair of colliding keys" do
          yielded = []
          hash = H[DeterministicHash.new('a', 1) => 1, DeterministicHash.new('b', 1) => 1]
          hash.each { |k,v| yielded << k }
          yielded.size.should == 2
          yielded.map { |x| x.value }.sort.should == ['a', 'b']
        end

        it "yields only the key to a block expecting |key,|" do
          keys = []
          hash.each { |key,| keys << key }
          keys.sort.should == ["A", "B", "C"]
        end
      end

      context "with no block" do
        it "returns an Enumerator" do
          @result = hash.send(method)
          @result.class.should be(Enumerator)
          @result.to_a.should == hash.to_a
        end
      end
    end
  end

  describe "#each_key" do
    it "yields all keys" do
      keys = []
      hash.each_key { |k| keys << k }
      keys.sort.should == ['A', 'B', 'C']
    end

    context "with no block" do
      it "returns an Enumerator" do
        hash.each_key.class.should be(Enumerator)
        hash.each_key.to_a.sort.should == ['A', 'B', 'C']
      end
    end
  end

  describe "#each_value" do
    it "yields all values" do
      values = []
      hash.each_value { |v| values << v }
      values.sort.should == ['aye', 'bee', 'see']
    end

    context "with no block" do
      it "returns an Enumerator" do
        hash.each_value.class.should be(Enumerator)
        hash.each_value.to_a.sort.should == ['aye', 'bee', 'see']
      end
    end
  end
end
