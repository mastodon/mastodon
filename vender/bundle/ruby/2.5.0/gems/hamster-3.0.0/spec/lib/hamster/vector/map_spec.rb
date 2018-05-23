require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  [:map, :collect].each do |method|
    describe "##{method}" do
      context "when empty" do
        let(:vector) { V.empty }

        it "returns self" do
          vector.send(method) {}.should equal(vector)
        end
      end

      context "when not empty" do
        let(:vector) { V["A", "B", "C"] }

        context "with a block" do
          it "preserves the original values" do
            vector.send(method, &:downcase)
            vector.should eql(V["A", "B", "C"])
          end

          it "returns a new vector with the mapped values" do
            vector.send(method, &:downcase).should eql(V["a", "b", "c"])
          end
        end

        context "with no block" do
          it "returns an Enumerator" do
            vector.send(method).class.should be(Enumerator)
            vector.send(method).each(&:downcase).should eql(V['a', 'b', 'c'])
          end
        end
      end

      context "from a subclass" do
        it "returns an instance of the subclass" do
          subclass = Class.new(Hamster::Vector)
          instance = subclass[1,2,3]
          instance.map { |x| x + 1 }.class.should be(subclass)
        end
      end

      context "on a large vector" do
        it "works" do
          V.new(1..2000).map { |x| x * 2 }.should eql(V.new((1..2000).map { |x| x * 2}))
        end
      end
    end
  end
end