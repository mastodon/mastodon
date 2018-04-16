require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  let(:hash) { H["A" => "aye", "B" => "bee", "C" => "see"] }

  describe "#take" do
    it "returns the first N key/val pairs from hash" do
      hash.take(0).should == []
      [[['A', 'aye']], [['B', 'bee']], [['C', 'see']]].include?(hash.take(1)).should == true
      [['A', 'aye'], ['B', 'bee'], ['C', 'see']].combination(2).include?(hash.take(2).sort).should == true
      hash.take(3).sort.should == [['A', 'aye'], ['B', 'bee'], ['C', 'see']]
      hash.take(4).sort.should == [['A', 'aye'], ['B', 'bee'], ['C', 'see']]
    end
  end

  describe "#take_while" do
    it "passes elements to the block until the block returns nil/false" do
      passed = nil
      hash.take_while { |k,v| passed = k; false }
      ['A', 'B', 'C'].include?(passed).should == true
    end

    it "returns an array of all elements before the one which returned nil/false" do
      count = 0
      result = hash.take_while { count += 1; count < 3 }
      [['A', 'aye'], ['B', 'bee'], ['C', 'see']].combination(2).include?(result.sort).should == true
    end

    it "passes all elements if the block never returns nil/false" do
      passed = []
      hash.take_while { |k,v| passed << [k, v]; true }.should == hash.to_a
      passed.sort.should == [['A', 'aye'], ['B', 'bee'], ['C', 'see']]
    end
  end
end