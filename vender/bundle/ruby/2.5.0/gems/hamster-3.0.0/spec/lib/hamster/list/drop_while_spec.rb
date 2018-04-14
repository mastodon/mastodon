require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#drop_while" do
    it "is lazy" do
      -> { Hamster.stream { fail }.drop_while { false } }.should_not raise_error
    end

    [
      [[], []],
      [["A"], []],
      [%w[A B C], ["C"]],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:list) { L[*values] }

        context "with a block" do
          it "preserves the original" do
            list.drop_while { |item| item < "C" }
            list.should eql(L[*values])
          end

          it "returns #{expected.inspect}" do
            list.drop_while { |item| item < "C" }.should eql(L[*expected])
          end
        end

        context "without a block" do
          it "returns an Enumerator" do
            list.drop_while.class.should be(Enumerator)
            list.drop_while.each { false }.should eql(list)
            list.drop_while.each { true  }.should be_empty
          end
        end
      end
    end
  end
end