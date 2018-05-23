require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  [:include?, :member?].each do |method|
    describe "##{method}" do
      let(:sorted_set) { SS[1, 2, 3, 4.0] }

      [1, 2, 3, 4.0].each do |value|
        it "returns true for an existing value (#{value.inspect})" do
          sorted_set.send(method, value).should == true
        end
      end

      it "returns false for a non-existing value" do
        sorted_set.send(method, 5).should == false
      end

      it "uses #<=> for equality" do
        sorted_set.send(method, 4).should == true
      end
    end
  end
end