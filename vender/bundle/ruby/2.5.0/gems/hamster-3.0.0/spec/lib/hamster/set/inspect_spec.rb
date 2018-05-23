require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  describe "#inspect" do
    [
      [[], "Hamster::Set[]"],
      [["A"], 'Hamster::Set["A"]'],
    ].each do |values, expected|
      describe "on #{values.inspect}" do
        let(:set) { S[*values] }

        it "returns #{expected.inspect}" do
          set.inspect.should == expected
        end

        it "returns a string which can be eval'd to get an equivalent set" do
          eval(set.inspect).should eql(set)
        end
      end
    end

    describe 'on ["A", "B", "C"]' do
      let(:set) { S["A", "B", "C"] }

      it "returns a programmer-readable representation of the set contents" do
        set.inspect.should match(/^Hamster::Set\["[A-C]", "[A-C]", "[A-C]"\]$/)
      end

      it "returns a string which can be eval'd to get an equivalent set" do
        eval(set.inspect).should eql(set)
      end
    end

    context "from a subclass" do
      MySet = Class.new(Hamster::Set)
      let(:set) { MySet[1, 2] }

      it "returns a programmer-readable representation of the set contents" do
        set.inspect.should match(/^MySet\[[1-2], [1-2]\]$/)
      end

      it "returns a string which can be eval'd to get an equivalent set" do
        eval(set.inspect).should eql(set)
      end
    end
  end
end