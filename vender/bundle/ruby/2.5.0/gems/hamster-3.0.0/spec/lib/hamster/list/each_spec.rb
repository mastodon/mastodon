require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#each" do
    context "on a really big list" do
      it "doesn't run out of stack" do
        -> { Hamster.interval(0, STACK_OVERFLOW_DEPTH).each { |item| } }.should_not raise_error
      end
    end

    [
      [],
      ["A"],
      %w[A B C],
    ].each do |values|
      context "on #{values.inspect}" do
        let(:list) { L[*values] }

        context "with a block" do
          it "iterates over the items in order" do
            yielded = []
            list.each { |item| yielded << item }
            yielded.should == values
          end

          it "returns nil" do
            list.each { |item| item }.should be_nil
          end
        end

        context "without a block" do
          it "returns an Enumerator" do
            list.each.class.should be(Enumerator)
            Hamster::List[*list.each].should eql(list)
          end
        end
      end
    end
  end
end
