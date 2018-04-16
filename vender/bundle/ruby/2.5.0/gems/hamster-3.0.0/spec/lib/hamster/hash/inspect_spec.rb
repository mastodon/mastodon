require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  describe "#inspect" do
    [
      [[], 'Hamster::Hash[]'],
      [["A" => "aye"], 'Hamster::Hash["A" => "aye"]'],
      [[DeterministicHash.new("A", 1) => "aye", DeterministicHash.new("B", 2) => "bee", DeterministicHash.new("C", 3) => "see"], 'Hamster::Hash["A" => "aye", "B" => "bee", "C" => "see"]']
    ].each do |values, expected|
      describe "on #{values.inspect}" do
        it "returns #{expected.inspect}" do
          H[*values].inspect.should == expected
        end
      end
    end

    [
      {},
      {"A" => "aye"},
      {a: "aye", b: "bee", c: "see"}
    ].each do |values|
      describe "on #{values.inspect}" do
        it "returns a string which can be eval'd to get an equivalent object" do
          original = H.new(values)
          eval(original.inspect).should eql(original)
        end
      end
    end
  end
end