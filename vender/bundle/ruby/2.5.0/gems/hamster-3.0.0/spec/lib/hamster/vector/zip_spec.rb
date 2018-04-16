require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#zip" do
    let(:vector) { V[1,2,3,4] }

    context "with a block" do
      it "yields arrays of one corresponding element from each input sequence" do
        result = []
        vector.zip(['a', 'b', 'c', 'd']) { |obj| result << obj }
        result.should eql([[1,'a'], [2,'b'], [3,'c'], [4,'d']])
      end

      it "fills in the missing values with nils" do
        result = []
        vector.zip(['a', 'b']) { |obj| result << obj }
        result.should eql([[1,'a'], [2,'b'], [3,nil], [4,nil]])
      end

      it "returns nil" do
        vector.zip([2,3,4]) {}.should be_nil
      end

      it "can handle multiple inputs, of different classes" do
        result = []
        vector.zip(V[2,3,4,5], [5,6,7,8]) { |obj| result << obj }
        result.should eql([[1,2,5], [2,3,6], [3,4,7], [4,5,8]])
      end
    end

    context "without a block" do
      it "returns a vector of arrays (one corresponding element from each input sequence)" do
        vector.zip([2,3,4,5]).should eql(V[[1,2], [2,3], [3,4], [4,5]])
      end
    end

    [10, 31, 32, 33, 1000, 1023, 1024, 1025].each do |size|
      context "on #{size}-item vectors" do
        it "behaves like Array#zip" do
          array   = (rand(9)+1).times.map { size.times.map { rand(10000) }}
          vectors = array.map { |a| V.new(a) }
          result  = vectors.first.zip(*vectors.drop(1))
          result.class.should be(Hamster::Vector)
          result.should == array[0].zip(*array.drop(1))
        end
      end
    end

    context "from a subclass" do
      it "returns an instance of the subclass" do
        subclass = Class.new(Hamster::Vector)
        instance = subclass.new([1,2,3])
        instance.zip([4,5,6]).class.should be(subclass)
      end
    end
  end
end