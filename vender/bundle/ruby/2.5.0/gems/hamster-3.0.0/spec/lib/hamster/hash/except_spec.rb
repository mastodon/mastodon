require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  describe "#except" do
    let(:hash) { H["A" => "aye", "B" => "bee", "C" => "see", nil => "NIL"] }

    context "with only keys that the Hash has" do
      it "returns a Hash without those values" do
        hash.except("B", nil).should eql(H["A" => "aye", "C" => "see"])
      end

      it "doesn't change the original Hash" do
        hash.except("B", nil)
        hash.should eql(H["A" => "aye", "B" => "bee", "C" => "see", nil => "NIL"])
      end
    end

    context "with keys that the Hash doesn't have" do
      it "returns a Hash without the values that it had keys for" do
        hash.except("B", "A", 3).should eql(H["C" => "see", nil => "NIL"])
      end

      it "doesn't change the original Hash" do
        hash.except("B", "A", 3)
        hash.should eql(H["A" => "aye", "B" => "bee", "C" => "see", nil => "NIL"])
      end
    end

    it "works on a large Hash, with many combinations of input" do
      keys = (1..1000).to_a
      original = H.new(keys.zip(2..1001))
      100.times do
        to_remove = rand(100).times.collect { keys.sample }
        result    = original.except(*to_remove)
        result.size.should == original.size - to_remove.uniq.size
        to_remove.each { |key| result.key?(key).should == false }
        (keys.sample(100) - to_remove).each { |key| result.key?(key).should == true }
      end
      original.should eql(H.new(keys.zip(2..1001))) # shouldn't have changed
    end
  end
end