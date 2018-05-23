require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#fill" do
    let(:list) { L[1, 2, 3, 4, 5, 6] }

    it "can replace a range of items at the beginning of a list" do
      list.fill(:a, 0, 3).should eql(L[:a, :a, :a, 4, 5, 6])
    end

    it "can replace a range of items in the middle of a list" do
      list.fill(:a, 3, 2).should eql(L[1, 2, 3, :a, :a, 6])
    end

    it "can replace a range of items at the end of a list" do
      list.fill(:a, 4, 2).should eql(L[1, 2, 3, 4, :a, :a])
    end

    it "can replace all the items in a list" do
      list.fill(:a, 0, 6).should eql(L[:a, :a, :a, :a, :a, :a])
    end

    it "can fill past the end of the list" do
      list.fill(:a, 3, 6).should eql(L[1, 2, 3, :a, :a, :a, :a, :a, :a])
    end

    context "with 1 argument" do
      it "replaces all the items in the list by default" do
        list.fill(:a).should eql(L[:a, :a, :a, :a, :a, :a])
      end
    end

    context "with 2 arguments" do
      it "replaces up to the end of the list by default" do
        list.fill(:a, 4).should eql(L[1, 2, 3, 4, :a, :a])
      end
    end

    context "when index and length are 0" do
      it "leaves the list unmodified" do
        list.fill(:a, 0, 0).should eql(list)
      end
    end

    it "is lazy" do
      -> { Hamster.stream { fail }.fill(:a, 0, 1) }.should_not raise_error
    end
  end
end