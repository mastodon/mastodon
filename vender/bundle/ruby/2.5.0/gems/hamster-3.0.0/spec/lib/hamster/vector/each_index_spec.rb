require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#each_index" do
    let(:vector) { V[1,2,3,4] }

    context "with a block" do
      it "yields all the valid indices into the vector" do
        result = []
        vector.each_index { |i| result << i }
        result.should eql([0,1,2,3])
      end

      it "returns self" do
        vector.each_index {}.should be(vector)
      end
    end

    context "without a block" do
      it "returns an Enumerator" do
        vector.each_index.class.should be(Enumerator)
        vector.each_index.to_a.should eql([0,1,2,3])
      end
    end

    context "on an empty vector" do
      it "doesn't yield anything" do
        V.empty.each_index { fail }
      end
    end

    [1, 2, 10, 31, 32, 33, 1000, 1024, 1025].each do |size|
      context "on a #{size}-item vector" do
        it "yields all valid indices" do
          V.new(1..size).each_index.to_a.should == (0..(size-1)).to_a
        end
      end
    end
  end
end