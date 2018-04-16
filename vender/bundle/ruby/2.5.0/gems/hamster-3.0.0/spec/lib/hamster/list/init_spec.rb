require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#init" do
    it "is lazy" do
      -> { Hamster.stream { false }.init }.should_not raise_error
    end

    [
      [[], []],
      [["A"], []],
      [%w[A B C], %w[A B]],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:list) { L[*values] }

        it "preserves the original" do
          list.init
          list.should eql(L[*values])
        end

        it "returns the list without the last element: #{expected.inspect}" do
          list.init.should eql(L[*expected])
        end
      end
    end
  end
end