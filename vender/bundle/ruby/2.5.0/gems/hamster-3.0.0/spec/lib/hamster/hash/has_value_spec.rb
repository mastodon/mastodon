require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  let(:hash) { H[toast: 'buttered', jam: 'strawberry'] }

  [:value?, :has_value?].each do |method|
    describe "##{method}" do
      it "returns true if any key/val pair in Hash has the same value" do
        hash.send(method, 'strawberry').should == true
      end

      it "returns false if no key/val pair in Hash has the same value" do
        hash.send(method, 'marmalade').should == false
      end

      it "uses #== to check equality" do
        H[a: EqualNotEql.new].send(method, EqualNotEql.new).should == true
        H[a: EqlNotEqual.new].send(method, EqlNotEqual.new).should == false
      end

      it "works on a large hash" do
        large = H.new((1..1000).zip(2..1001))
        [2, 100, 200, 500, 900, 1000, 1001].each { |n| large.value?(n).should == true }
      end
    end
  end
end