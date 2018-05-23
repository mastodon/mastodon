require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#each_with_index" do
    describe "with no block" do
      let(:vector) { V["A", "B", "C"] }

      it "returns an Enumerator" do
        vector.each_with_index.class.should be(Enumerator)
        vector.each_with_index.to_a.should == [['A', 0], ['B', 1], ['C', 2]]
      end
    end

    [1, 2, 31, 32, 33, 1023, 1024, 1025].each do |size|
      context "on a #{size}-item vector" do
        describe "with a block" do
          let(:vector) { V.new(1..size) }

          it "returns self" do
            pairs = []
            vector.each_with_index { |item, index| pairs << [item, index] }.should be(vector)
          end

          it "iterates over the items in order" do
            pairs = []
            vector.each_with_index { |item, index| pairs << [item, index] }.should be(vector)
            pairs.should == (1..size).zip(0..size.pred)
          end
        end
      end
    end

    context "on an empty vector" do
      it "doesn't yield anything" do
        V.empty.each_with_index { |item, index| fail }
      end
    end
  end
end