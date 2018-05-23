require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  [:select, :find_all].each do |method|
    describe "##{method}" do
      let(:sorted_set) { SS["A", "B", "C"] }

      context "when everything matches" do
        it "preserves the original" do
          sorted_set.send(method) { true }
          sorted_set.should eql(SS["A", "B", "C"])
        end

        it "returns self" do
          sorted_set.send(method) { |item| true }.should equal(sorted_set)
        end
      end

      context "when only some things match" do
        context "with a block" do
          it "preserves the original" do
            sorted_set.send(method) { |item| item == "A" }
            sorted_set.should eql(SS["A", "B", "C"])
          end

          it "returns a set with the matching values" do
            sorted_set.send(method) { |item| item == "A" }.should eql(SS["A"])
          end
        end

        context "with no block" do
          it "returns an Enumerator" do
            sorted_set.send(method).class.should be(Enumerator)
            sorted_set.send(method).each { |item| item == "A" }.should eql(SS["A"])
          end
        end
      end

      context "when nothing matches" do
        it "preserves the original" do
          sorted_set.send(method) { |item| false }
          sorted_set.should eql(SS["A", "B", "C"])
        end

        it "returns the canonical empty set" do
          sorted_set.send(method) { |item| false }.should equal(Hamster::EmptySortedSet)
        end
      end

      context "from a subclass" do
        it "returns an instance of the same class" do
          subclass = Class.new(Hamster::SortedSet)
          instance = subclass.new(['A', 'B', 'C'])
          instance.send(method) { true }.class.should be(subclass)
          instance.send(method) { false }.class.should be(subclass)
          instance.send(method) { rand(2) == 0 }.class.should be(subclass)
        end
      end
    end
  end
end