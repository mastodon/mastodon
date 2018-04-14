require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  let(:hash) { H["A" => "aye", "B" => "bee", "C" => "see"] }

  describe "#flat_map" do
    it "yields each key/val pair" do
      passed = []
      hash.flat_map { |pair| passed << pair }
      passed.sort.should == [['A', 'aye'], ['B', 'bee'], ['C', 'see']]
    end

    it "returns the concatenation of block return values" do
      hash.flat_map { |k,v| [k,v] }.sort.should == ['A', 'B', 'C', 'aye', 'bee', 'see']
      hash.flat_map { |k,v| L[k,v] }.sort.should == ['A', 'B', 'C', 'aye', 'bee', 'see']
      hash.flat_map { |k,v| V[k,v] }.sort.should == ['A', 'B', 'C', 'aye', 'bee', 'see']
    end

    it "doesn't change the receiver" do
      hash.flat_map { |k,v| [k,v] }
      hash.should eql(H["A" => "aye", "B" => "bee", "C" => "see"])
    end

    context "with no block" do
      it "returns an Enumerator" do
        hash.flat_map.class.should be(Enumerator)
        hash.flat_map.each { |k,v| [k] }.sort.should == ['A', 'B', 'C']
      end
    end

    it "returns an empty array if only empty arrays are returned by block" do
      hash.flat_map { [] }.should eql([])
    end
  end
end