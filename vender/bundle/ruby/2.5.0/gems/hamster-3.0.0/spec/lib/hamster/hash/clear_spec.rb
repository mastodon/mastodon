require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  describe "#clear" do
    [
      [],
      ["A" => "aye"],
      ["A" => "aye", "B" => "bee", "C" => "see"],
    ].each do |values|
      context "on #{values}" do
        let(:original) { H[*values] }
        let(:result)   { original.clear }

        it "preserves the original" do
          result
          original.should eql(H[*values])
        end

        it "returns an empty hash" do
          result.should equal(H.empty)
          result.should be_empty
        end
      end
    end

    it "maintains the default Proc, if there is one" do
      hash = H.new(a: 1) { 1 }
      hash.clear[:b].should == 1
      hash.clear[:c].should == 1
      hash.clear.default_proc.should_not be_nil
    end

    context "on a subclass" do
      it "returns an empty instance of the subclass" do
        subclass = Class.new(Hamster::Hash)
        instance = subclass.new(a: 1, b: 2)
        instance.clear.class.should be(subclass)
        instance.clear.should be_empty
      end
    end
  end
end