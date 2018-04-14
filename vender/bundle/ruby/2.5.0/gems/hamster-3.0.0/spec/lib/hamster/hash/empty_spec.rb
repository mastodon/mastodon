require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  describe "#empty?" do
    [
      [[], true],
      [["A" => "aye"], false],
      [["A" => "aye", "B" => "bee", "C" => "see"], false],
    ].each do |pairs, result|
      it "returns #{result} for #{pairs.inspect}" do
        H[*pairs].empty?.should == result
      end
    end

    it "returns true for empty hashes which have a default block" do
      H.new { 'default' }.empty?.should == true
    end
  end

  describe ".empty" do
    it "returns the canonical empty Hash" do
      H.empty.should be_empty
      H.empty.should be(Hamster::EmptyHash)
    end

    context "from a subclass" do
      it "returns an empty instance of the subclass" do
        subclass = Class.new(Hamster::Hash)
        subclass.empty.class.should be subclass
        subclass.empty.should be_empty
      end

      it "calls overridden #initialize when creating empty Hash" do
        subclass = Class.new(Hamster::Hash) do
          def initialize
            @variable = 'value'
          end
        end
        subclass.empty.instance_variable_get(:@variable).should == 'value'
      end
    end
  end
end