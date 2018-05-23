require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#grep" do
    it "is lazy" do
      -> { Hamster.stream { fail }.grep(Object) { |item| item } }.should_not raise_error
    end

    context "without a block" do
      [
        [[], []],
        [["A"], ["A"]],
        [[1], []],
        [["A", 2, "C"], %w[A C]],
      ].each do |values, expected|
        context "on #{values.inspect}" do
          it "returns #{expected.inspect}" do
            L[*values].grep(String).should eql(L[*expected])
          end
        end
      end
    end

    context "with a block" do
      [
        [[], []],
        [["A"], ["a"]],
        [[1], []],
        [["A", 2, "C"], %w[a c]],
      ].each do |values, expected|
        context "on #{values.inspect}" do
          let(:list) { L[*values] }

          it "preserves the original" do
            list.grep(String, &:downcase)
            list.should eql(L[*values])
          end

          it "returns #{expected.inspect}" do
            list.grep(String, &:downcase).should eql(L[*expected])
          end
        end
      end
    end
  end
end