require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#reverse" do
    context "on a really big list" do
      it "doesn't run out of stack" do
        -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).reverse }.should_not raise_error
      end
    end

    it "is lazy" do
      -> { Hamster.stream { fail }.reverse }.should_not raise_error
    end

    [
      [[], []],
      [["A"], ["A"]],
      [%w[A B C], %w[C B A]],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:list) { L[*values] }

        it "preserves the original" do
          list.reverse { |item| item.downcase }
          list.should eql(L[*values])
        end

        it "returns #{expected.inspect}" do
          list.reverse { |item| item.downcase }.should == L[*expected]
        end
      end
    end
  end
end