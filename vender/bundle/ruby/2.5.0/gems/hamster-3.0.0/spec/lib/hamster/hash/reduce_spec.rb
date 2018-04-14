require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  [:reduce, :inject].each do |method|
    describe "##{method}" do
      context "when empty" do
        it "returns the memo" do
          H.empty.send(method, "ABC") {}.should == "ABC"
        end
      end

      context "when not empty" do
        let(:hash) { H["A" => "aye", "B" => "bee", "C" => "see"] }

        context "with a block" do
          it "returns the final memo" do
            hash.send(method, 0) { |memo, key, value| memo + 1 }.should == 3
          end
        end

        context "with no block" do
          let(:hash) { H[a: 1, b: 2] }

          it "uses a passed string as the name of a method to use instead" do
            [[:a, 1, :b, 2], [:b, 2, :a, 1]].include?(hash.send(method, "+")).should == true
          end

          it "uses a passed symbol as the name of a method to use instead" do
            [[:a, 1, :b, 2], [:b, 2, :a, 1]].include?(hash.send(method, :+)).should == true
          end
        end
      end
    end
  end
end
