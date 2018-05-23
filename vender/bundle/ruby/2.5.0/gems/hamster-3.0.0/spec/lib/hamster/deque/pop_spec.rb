require "spec_helper"
require "hamster/deque"

describe Hamster::Deque do
  describe "#pop" do
    [
      [[], []],
      [["A"], []],
      [%w[A B C], %w[A B]],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:deque) { D[*values] }

        it "preserves the original" do
          deque.pop
          deque.should eql(D[*values])
        end

        it "returns #{expected.inspect}" do
          deque.pop.should eql(D[*expected])
        end

        it "returns a frozen instance" do
          deque.pop.should be_frozen
        end
      end
    end

    context "on empty subclass" do
      let(:subclass) { Class.new(Hamster::Deque) }
      let(:empty_instance) { subclass.new }
      it "returns emtpy object of same class" do
        empty_instance.pop.class.should be subclass
      end
    end
  end
end