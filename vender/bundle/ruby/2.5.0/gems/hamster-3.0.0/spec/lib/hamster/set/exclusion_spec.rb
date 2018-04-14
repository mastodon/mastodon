require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  [:exclusion, :^].each do |method|
    describe "##{method}" do
      [
        [[], [], []],
        [["A"], [], ["A"]],
        [["A"], ["A"], []],
        [%w[A B C], ["B"], %w[A C]],
        [%w[A B C], %w[B C D], %w[A D]],
        [%w[A B C], %w[D E F], %w[A B C D E F]],
      ].each do |a, b, expected|
        context "for #{a.inspect} and #{b.inspect}" do
          let(:set_a) { S[*a] }
          let(:set_b) { S[*b] }
          let(:result) { set_a.send(method, set_b) }

          it "doesn't modify the original Sets" do
            result
            set_a.should eql(S.new(a))
            set_b.should eql(S.new(b))
          end

          it "returns #{expected.inspect}"  do
            result.should eql(S[*expected])
          end
        end

        context "when passed a Ruby Array" do
          it "returns the expected Set" do
            S[*a].exclusion(b.freeze).should eql(S[*expected])
          end
        end
      end

      it "works for a wide variety of inputs" do
        50.times do
          array1 = (1..400).to_a.sample(100)
          array2 = (1..400).to_a.sample(100)
          result = S.new(array1) ^ S.new(array2)
          result.to_a.sort.should eql(((array1 | array2) - (array1 & array2)).sort)
        end
      end
    end
  end
end