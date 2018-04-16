require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  [:map, :collect].each do |method|
    describe "##{method}" do
      context "when empty" do
        it "returns self" do
          SS.empty.send(method) {}.should equal(SS.empty)
        end
      end

      context "when not empty" do
        let(:sorted_set) { SS["A", "B", "C"] }

        context "with a block" do
          it "preserves the original values" do
            sorted_set.send(method, &:downcase)
            sorted_set.should eql(SS["A", "B", "C"])
          end

          it "returns a new set with the mapped values" do
            sorted_set.send(method, &:downcase).should eql(SS["a", "b", "c"])
          end
        end

        context "with no block" do
          it "returns an Enumerator" do
            sorted_set.send(method).class.should be(Enumerator)
            sorted_set.send(method).each(&:downcase).should == SS['a', 'b', 'c']
          end
        end
      end

      context "on a set ordered by a comparator" do
        let(:sorted_set) { SS.new(["A", "B", "C"]) { |a,b| b <=> a }}

        it "returns a new set with the mapped values" do
          sorted_set.send(method, &:downcase).should == ['c', 'b', 'a']
        end
      end
    end
  end
end