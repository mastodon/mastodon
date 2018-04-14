require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#bsearch" do
    let(:vector) { V[5,10,20,30] }

    context "with a block which returns false for elements below desired position, and true for those at/above" do
      it "returns the first element for which the predicate is true" do
        vector.bsearch { |x| x > 10 }.should be(20)
        vector.bsearch { |x| x > 1 }.should be(5)
        vector.bsearch { |x| x > 25 }.should be(30)
      end

      context "if the block always returns false" do
        it "returns nil" do
          vector.bsearch { false }.should be_nil
        end
      end

      context "if the block always returns true" do
        it "returns the first element" do
          vector.bsearch { true }.should be(5)
        end
      end
    end

    context "with a block which returns a negative number for elements below desired position, zero for the right element, and positive for those above" do
      it "returns the element for which the block returns zero" do
        vector.bsearch { |x| x <=> 10 }.should be(10)
      end

      context "if the block always returns positive" do
        it "returns nil" do
          vector.bsearch { 1 }.should be_nil
        end
      end

      context "if the block always returns negative" do
        it "returns nil" do
          vector.bsearch { -1 }.should be_nil
        end
      end

      context "if the block returns sometimes positive, sometimes negative, but never zero" do
        it "returns nil" do
          vector.bsearch { |x| x <=> 11 }.should be_nil
        end
      end

      context "if not passed a block" do
        it "returns an Enumerator" do
          enum = vector.bsearch
          enum.should be_a(Enumerator)
          enum.each { |x| x <=> 10 }.should == 10
        end
      end
    end

    context "on an empty vector" do
      it "returns nil" do
        V.empty.bsearch { |x| x > 5 }.should be_nil
      end
    end
  end
end