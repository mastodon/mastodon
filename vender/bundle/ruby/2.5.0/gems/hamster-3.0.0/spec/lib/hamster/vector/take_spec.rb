require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#take" do
    [
      [[], 10, []],
      [["A"], 10, ["A"]],
      [%w[A B C], 0, []],
      [%w[A B C], 2, %w[A B]],
      [(1..32), 1, [1]],
      [(1..33), 32, (1..32)],
      [(1..100), 40, (1..40)]
    ].each do |values, number, expected|
      describe "#{number} from #{values.inspect}" do
        let(:vector) { V[*values] }

        it "preserves the original" do
          vector.take(number)
          vector.should eql(V[*values])
        end

        it "returns #{expected.inspect}" do
          vector.take(number).should eql(V[*expected])
        end
      end
    end

    context "when number of elements specified is identical to size" do
      let(:vector) { V[1, 2, 3, 4, 5, 6] }
      it "returns self" do
        vector.take(vector.size).should be(vector)
      end
    end

    context "when number of elements specified is bigger than size" do
      let(:vector) { V[1, 2, 3, 4, 5, 6] }
      it "returns self" do
        vector.take(vector.size + 1).should be(vector)
      end
    end
  end
end