require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#add" do
    [
      [[], "A", ["A"]],
      [["A"], "B", %w[B A]],
      [["A"], "A", %w[A A]],
      [%w[A B C], "D", %w[D A B C]],
    ].each do |values, new_value, expected|
      context "on #{values.inspect} with #{new_value.inspect}" do
        let(:list) { L[*values] }

        it "preserves the original" do
          list.add(new_value)
          list.should eql(L[*values])
        end

        it "returns #{expected.inspect}" do
          list.add(new_value).should eql(L[*expected])
        end
      end
    end
  end
end