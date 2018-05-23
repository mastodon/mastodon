require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#insert" do
    let(:original) { L[1, 2, 3] }

    it "can add items at the beginning of a list" do
      list = original.insert(0, :a, :b)
      list.size.should be(5)
      list.at(0).should be(:a)
      list.at(2).should be(1)
    end

    it "can add items in the middle of a list" do
      list = original.insert(1, :a, :b, :c)
      list.size.should be(6)
      list.to_a.should == [1, :a, :b, :c, 2, 3]
    end

    it "can add items at the end of a list" do
      list = original.insert(3, :a, :b, :c)
      list.size.should be(6)
      list.to_a.should == [1, 2, 3, :a, :b, :c]
    end

    it "can add items past the end of a list" do
      list = original.insert(6, :a, :b)
      list.size.should be(8)
      list.to_a.should == [1, 2, 3, nil, nil, nil, :a, :b]
    end

    it "accepts a negative index, which counts back from the end of the list" do
      list = original.insert(-2, :a)
      list.size.should be(4)
      list.to_a.should == [1, :a, 2, 3]
    end

    it "raises IndexError if a negative index is too great" do
      expect { original.insert(-4, :a) }.to raise_error(IndexError)
    end

    it "is lazy" do
      -> { Hamster.stream { fail }.insert(0, :a) }.should_not raise_error
    end
  end
end