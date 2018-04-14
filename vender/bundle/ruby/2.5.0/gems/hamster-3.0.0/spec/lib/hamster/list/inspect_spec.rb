require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#inspect" do
    context "on a really big list" do
      it "doesn't run out of stack" do
        -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).inspect }.should_not raise_error
      end
    end

    [
      [[], 'Hamster::List[]'],
      [["A"], 'Hamster::List["A"]'],
      [%w[A B C], 'Hamster::List["A", "B", "C"]']
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:list) { L[*values] }

        it "returns #{expected.inspect}" do
          list.inspect.should == expected
        end

        it "returns a string which can be eval'd to get an equivalent object" do
          eval(list.inspect).should eql(list)
        end
      end
    end
  end
end