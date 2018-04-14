require "spec_helper"
require "hamster/deque"

describe Hamster::Deque do
  describe "#push" do
    [
      [[], "A", ["A"]],
      [["A"], "B", %w[A B]],
      [%w[A B C], "D", %w[A B C D]],
    ].each do |original, item, expected|
      context "pushing #{item.inspect} into #{original.inspect}" do
        let(:deque) { D.new(original) }

        it "preserves the original" do
          deque.push(item)
          deque.should eql(D.new(original))
        end

        it "returns #{expected.inspect}" do
          deque.push(item).should eql(D.new(expected))
        end

        it "returns a frozen instance" do
          deque.push(item).should be_frozen
        end
      end
    end

    context "on a subclass" do
      let(:subclass) { Class.new(Hamster::Deque) }
      let(:empty_instance) { subclass.new }
      it "returns an object of same class" do
        empty_instance.push(1).class.should be subclass
      end
    end
  end
end