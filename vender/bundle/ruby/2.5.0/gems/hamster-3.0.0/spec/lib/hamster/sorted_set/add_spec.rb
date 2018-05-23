require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  let(:sorted_set) { SS["B", "C", "D"] }

  [:add, :<<].each do |method|
    describe "##{method}" do
      context "with a unique value" do
        it "preserves the original" do
          sorted_set.send(method, "A")
          sorted_set.should eql(SS["B", "C", "D"])
        end

        it "returns a copy with the superset of values (in order)" do
          sorted_set.send(method, "A").should eql(SS["A", "B", "C", "D"])
        end
      end

      context "with a duplicate value" do
        it "preserves the original values" do
          sorted_set.send(method, "C")
          sorted_set.should eql(SS["B", "C", "D"])
        end

        it "returns self" do
          sorted_set.send(method, "C").should equal(sorted_set)
        end
      end

      context "on a set ordered by a comparator" do
        it "inserts the new item in the correct place" do
          s = SS.new(['tick', 'pig', 'hippopotamus']) { |str| str.length }
          s.add('giraffe').to_a.should == ['pig', 'tick', 'giraffe', 'hippopotamus']
        end
      end
    end
  end

  describe "#add?" do
    context "with a unique value" do
      it "preserves the original" do
        sorted_set.add?("A")
        sorted_set.should eql(SS["B", "C", "D"])
      end

      it "returns a copy with the superset of values" do
        sorted_set.add?("A").should eql(SS["A", "B", "C", "D"])
      end
    end

    context "with a duplicate value" do
      it "preserves the original values" do
        sorted_set.add?("C")
        sorted_set.should eql(SS["B", "C", "D"])
      end

      it "returns false" do
        sorted_set.add?("C").should equal(false)
      end
    end
  end
end