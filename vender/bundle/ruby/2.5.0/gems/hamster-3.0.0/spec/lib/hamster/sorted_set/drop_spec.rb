require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#drop" do
    [
      [[], 0, []],
      [[], 10, []],
      [["A"], 10, []],
      [%w[A B C], 0, %w[A B C]],
      [%w[A B C], 1, %w[B C]],
      [%w[A B C], 2, ["C"]],
      [%w[A B C], 3, []]
    ].each do |values, number, expected|
      context "#{number} from #{values.inspect}" do
        let(:sorted_set) { SS[*values] }

        it "preserves the original" do
          sorted_set.drop(number)
          sorted_set.should eql(SS[*values])
        end

        it "returns #{expected.inspect}" do
          sorted_set.drop(number).should eql(SS[*expected])
        end
      end
    end

    context "when argument is zero" do
      let(:sorted_set) { SS[6, 7, 8, 9] }
      it "returns self" do
        sorted_set.drop(0).should be(sorted_set)
      end
    end

    context "when the set has a custom order" do
      let(:sorted_set) { SS.new([1, 2, 3]) { |x| -x }}
      it "maintains the custom order" do
        sorted_set.drop(1).to_a.should == [2, 1]
        sorted_set.drop(2).to_a.should == [1]
      end

      it "keeps the comparator even when set is cleared" do
        s = sorted_set.drop(3)
        s.add(4).add(5).add(6).to_a.should == [6, 5, 4]
      end
    end

    context "when called on a subclass" do
      it "should return an instance of the subclass" do
        subclass = Class.new(Hamster::SortedSet)
        subclass.new([1,2,3]).drop(1).class.should be(subclass)
      end
    end
  end
end