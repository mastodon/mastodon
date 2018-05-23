require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#fill" do
    let(:vector) { V[1, 2, 3, 4, 5, 6] }

    it "can replace a range of items at the beginning of a vector" do
      vector.fill(:a, 0, 3).should eql(V[:a, :a, :a, 4, 5, 6])
    end

    it "can replace a range of items in the middle of a vector" do
      vector.fill(:a, 3, 2).should eql(V[1, 2, 3, :a, :a, 6])
    end

    it "can replace a range of items at the end of a vector" do
      vector.fill(:a, 4, 2).should eql(V[1, 2, 3, 4, :a, :a])
    end

    it "can replace all the items in a vector" do
      vector.fill(:a, 0, 6).should eql(V[:a, :a, :a, :a, :a, :a])
    end

    it "can fill past the end of the vector" do
      vector.fill(:a, 3, 6).should eql(V[1, 2, 3, :a, :a, :a, :a, :a, :a])
    end

    context "with 1 argument" do
      it "replaces all the items in the vector by default" do
        vector.fill(:a).should eql(V[:a, :a, :a, :a, :a, :a])
      end
    end

    context "with 2 arguments" do
      it "replaces up to the end of the vector by default" do
        vector.fill(:a, 4).should eql(V[1, 2, 3, 4, :a, :a])
      end
    end

    context "when index and length are 0" do
      it "leaves the vector unmodified" do
        vector.fill(:a, 0, 0).should eql(vector)
      end
    end

    context "when expanding a vector past boundary where vector trie needs to deepen" do
      it "works the same" do
        vector.fill(:a, 32, 3).size.should == 35
        vector.fill(:a, 32, 3).to_a.size.should == 35
      end
    end

    [1000, 1023, 1024, 1025, 2000].each do |size|
      context "on a #{size}-item vector" do
        it "works the same" do
          array = (0..size).to_a
          vector = V.new(array)
          [[:a, 0, 5], [:b, 31, 2], [:c, 32, 60], [:d, 1000, 20], [:e, 1024, 33], [:f, 1200, 35]].each do |obj, index, length|
            next if index > size
            vector = vector.fill(obj, index, length)
            array.fill(obj, index, length)
            vector.size.should == array.size
            ary = vector.to_a
            ary.size.should == vector.size
            ary.should eql(array)
          end
        end
      end
    end

    it "behaves like Array#fill, on a variety of inputs" do
      50.times do
        array = rand(100).times.map { rand(1000) }
        index = rand(array.size)
        length = rand(50)
        V.new(array).fill(:a, index, length).should == array.fill(:a, index, length)
      end
      10.times do
        array = rand(100).times.map { rand(10000) }
        length = rand(100)
        V.new(array).fill(:a, array.size, length).should == array.fill(:a, array.size, length)
      end
      10.times do
        array = rand(100).times.map { rand(10000) }
        V.new(array).fill(:a).should == array.fill(:a)
      end
    end
  end
end