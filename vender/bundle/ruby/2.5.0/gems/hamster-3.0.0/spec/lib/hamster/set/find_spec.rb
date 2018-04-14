require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  [:find, :detect].each do |method|
    describe "##{method}" do
      [
        [[], "A", nil],
        [[], nil, nil],
        [["A"], "A", "A"],
        [["A"], "B", nil],
        [["A"], nil, nil],
        [["A", "B", nil], "A", "A"],
        [["A", "B", nil], "B", "B"],
        [["A", "B", nil], nil, nil],
        [["A", "B", nil], "C", nil],
      ].each do |values, item, expected|
        describe "on #{values.inspect}" do
          context "with a block" do
            it "returns #{expected.inspect}" do
              S[*values].send(method) { |x| x == item }.should == expected
            end
          end

          context "without a block" do
            it "returns an Enumerator" do
              result = S[*values].send(method)
              result.class.should be(Enumerator)
              result.each { |x| x == item}.should == expected
            end
          end
        end
      end
    end
  end
end