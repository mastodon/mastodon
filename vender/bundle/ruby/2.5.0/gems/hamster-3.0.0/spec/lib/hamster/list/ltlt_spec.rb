require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#<<" do
    it "adds an item onto the end of a list" do
      list = L["a", "b"]
      (list << "c").should eql(L["a", "b", "c"])
      list.should eql(L["a", "b"])
    end

    context "on an empty list" do
      it "returns a list with one item" do
        list = L.empty
        (list << "c").should eql(L["c"])
        list.should eql(L.empty)
      end
    end
  end
end