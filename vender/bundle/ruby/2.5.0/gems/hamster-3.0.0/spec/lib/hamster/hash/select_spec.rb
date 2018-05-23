require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  [:select, :find_all, :keep_if].each do |method|
    describe "##{method}" do
      let(:original) { H["A" => "aye", "B" => "bee", "C" => "see"] }

      context "when everything matches" do
        it "returns self" do
          original.send(method) { |key, value| true }.should equal(original)
        end
      end

      context "when only some things match" do
        context "with a block" do
          let(:result) { original.send(method) { |key, value| key == "A" && value == "aye" }}

          it "preserves the original" do
            original.should eql(H["A" => "aye", "B" => "bee", "C" => "see"])
          end

          it "returns a set with the matching values" do
            result.should eql(H["A" => "aye"])
          end
        end

        it "yields entries as [key, value] pairs" do
          original.send(method) do |e|
            e.should be_kind_of(Array)
            ["A", "B", "C"].include?(e[0]).should == true
            ["aye", "bee", "see"].include?(e[1]).should == true
          end
        end

        context "with no block" do
          it "returns an Enumerator" do
            original.send(method).class.should be(Enumerator)
            original.send(method).to_a.sort.should == [['A', 'aye'], ['B', 'bee'], ['C', 'see']]
          end
        end
      end

      it "works on a large hash, with many combinations of input" do
        keys = (1..1000).to_a
        original = H.new(keys.zip(2..1001))
        25.times do
          threshold = rand(1000)
          result    = original.send(method) { |k,v| k <= threshold }
          result.size.should == threshold
          result.each_key { |k| k.should <= threshold }
          (threshold+1).upto(1000) { |k| result.key?(k).should == false }
        end
        original.should eql(H.new(keys.zip(2..1001))) # shouldn't have changed
      end
    end
  end
end