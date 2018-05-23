require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#compact" do
    it "is lazy" do
      -> { Hamster.stream { fail }.compact }.should_not raise_error
    end

    [
      [[], []],
      [["A"], ["A"]],
      [%w[A B C], %w[A B C]],
      [[nil], []],
      [[nil, "B"], ["B"]],
      [["A", nil], ["A"]],
      [[nil, nil], []],
      [["A", nil, "C"], %w[A C]],
      [[nil, "B", nil], ["B"]],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:list) { L[*values] }

        it "preserves the original" do
          list.compact
          list.should eql(L[*values])
        end

        it "returns #{expected.inspect}" do
          list.compact.should eql(L[*expected])
        end
      end
    end
  end
end