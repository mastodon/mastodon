require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#delete_at" do
    let(:list) { L[1,2,3,4,5] }

    it "removes the element at the specified index" do
      list.delete_at(0).should eql(L[2,3,4,5])
      list.delete_at(2).should eql(L[1,2,4,5])
      list.delete_at(-1).should eql(L[1,2,3,4])
    end

    it "makes no modification if the index is out of range" do
      list.delete_at(5).should eql(list)
      list.delete_at(-6).should eql(list)
    end
  end
end