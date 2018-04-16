require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#transpose" do
    it "takes a list of lists and returns a list of all the first elements, all the 2nd elements, and so on" do
      L[L[1, 'a'], L[2, 'b'], L[3, 'c']].transpose.should eql(L[L[1, 2, 3], L["a", "b", "c"]])
      L[L[1, 2, 3], L["a", "b", "c"]].transpose.should eql(L[L[1, 'a'], L[2, 'b'], L[3, 'c']])
      L[].transpose.should eql(L[])
      L[L[]].transpose.should eql(L[])
      L[L[], L[]].transpose.should eql(L[])
      L[L[0]].transpose.should eql(L[L[0]])
      L[L[0], L[1]].transpose.should eql(L[L[0, 1]])
    end

    it "only goes as far as the shortest list" do
      L[L[1,2,3], L[2]].transpose.should eql(L[L[1,2]])
    end
  end
end