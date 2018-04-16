require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  [:select, :find_all].each do |method|
    describe "##{method}" do
      let(:set) { S["A", "B", "C"] }

      context "when everything matches" do
        it "returns self" do
          set.send(method) { |item| true }.should equal(set)
        end
      end

      context "when only some things match" do
        context "with a block" do
          let(:result) { set.send(method) { |item| item == "A" }}

          it "preserves the original" do
            result
            set.should eql(S["A", "B", "C"])
          end

          it "returns a set with the matching values" do
            result.should eql(S["A"])
          end
        end

        context "with no block" do
          it "returns an Enumerator" do
            set.send(method).class.should be(Enumerator)
            set.send(method).each { |item| item == "A" }.should eql(S["A"])
          end
        end
      end

      context "when nothing matches" do
        let(:result) { set.send(method) { |item| false }}

        it "preserves the original" do
          result
          set.should eql(S["A", "B", "C"])
        end

        it "returns the canonical empty set" do
          result.should equal(Hamster::EmptySet)
        end
      end

      context "from a subclass" do
        it "returns an instance of the same class" do
          subclass = Class.new(Hamster::Set)
          instance = subclass.new(['A', 'B', 'C'])
          instance.send(method) { true }.class.should be(subclass)
          instance.send(method) { false }.class.should be(subclass)
          instance.send(method) { rand(2) == 0 }.class.should be(subclass)
        end
      end

      it "works on a large set, with many combinations of input" do
        items = (1..1000).to_a
        original = S.new(items)
        30.times do
          threshold = rand(1000)
          result    = original.send(method) { |item| item <= threshold }
          result.size.should == threshold
          result.each { |item| item.should <= threshold }
          (threshold+1).upto(1000) { |item| result.include?(item).should == false }
        end
        original.should eql(S.new(items))
      end
    end
  end
end