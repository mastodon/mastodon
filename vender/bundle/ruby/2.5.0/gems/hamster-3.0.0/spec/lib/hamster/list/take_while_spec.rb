require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#take_while" do
    it "is lazy" do
      -> { Hamster.stream { fail }.take_while { false } }.should_not raise_error
    end

    [
      [[], []],
      [["A"], ["A"]],
      [%w[A B C], %w[A B]],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:list) { L[*values] }

        context "with a block" do
          it "returns #{expected.inspect}" do
            list.take_while { |item| item < "C" }.should eql(L[*expected])
          end

          it "preserves the original" do
            list.take_while { |item| item < "C" }
            list.should eql(L[*values])
          end

          it "is lazy" do
            count = 0
            list.take_while do |item|
              count += 1
              true
            end
            count.should <= 1
          end
        end

        context "without a block" do
          it "returns an Enumerator" do
            list.take_while.class.should be(Enumerator)
            list.take_while.each { |item| item < "C" }.should eql(L[*expected])
          end
        end
      end
    end
  end
end
