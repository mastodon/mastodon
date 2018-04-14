require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#join" do
    context "on a really big list" do
      it "doesn't run out of stack" do
        -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).join }.should_not raise_error
      end
    end

    context "with a separator" do
      [
        [[], ""],
        [["A"], "A"],
        [%w[A B C], "A|B|C"]
      ].each do |values, expected|
        context "on #{values.inspect}" do
          let(:list) { L[*values] }

          it "preserves the original" do
            list.join("|")
            list.should eql(L[*values])
          end

          it "returns #{expected.inspect}" do
            list.join("|").should == expected
          end
        end
      end
    end

    context "without a separator" do
      [
        [[], ""],
        [["A"], "A"],
        [%w[A B C], "ABC"]
      ].each do |values, expected|
        context "on #{values.inspect}" do
          let(:list) { L[*values] }

          it "preserves the original" do
            list.join
            list.should eql(L[*values])
          end

          it "returns #{expected.inspect}" do
            list.join.should == expected
          end
        end
      end
    end

    context "without a separator (with global default separator set)" do
      before { $, = '**' }
      let(:list) { L["A", "B", "C"] }
      after  { $, = nil }

      it "uses the default global separator" do
        list.join.should == "A**B**C"
      end
    end
  end
end