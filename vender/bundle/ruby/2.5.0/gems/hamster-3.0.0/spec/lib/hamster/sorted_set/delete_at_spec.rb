require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  describe "#delete_at" do
    let(:sorted_set) { SS[1,2,3,4,5] }

    it "removes the element at the specified index" do
      sorted_set.delete_at(0).should  eql(SS[2,3,4,5])
      sorted_set.delete_at(2).should  eql(SS[1,2,4,5])
      sorted_set.delete_at(-1).should eql(SS[1,2,3,4])
    end

    it "makes no modification if the index is out of range" do
      sorted_set.delete_at(5).should eql(sorted_set)
      sorted_set.delete_at(-6).should eql(sorted_set)
    end
  end
end