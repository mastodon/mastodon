require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  [:difference, :subtract, :-].each do |method|
    describe "##{method}" do
      [
        [[], [], []],
        [["A"], [], ["A"]],
        [["A"], ["A"], []],
        [%w[A B C], ["B"], %w[A C]],
        [%w[A B C], %w[A C], ["B"]],
        [%w[A B C D E F G H], [], %w[A B C D E F G H]],
        [%w[A B C M X Y Z], %w[B C D E F G H I J X], %w[A M Y Z]]
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
            S[*a].difference(b.freeze).should eql(S[*expected])
          end
        end
      end

      it "works on a wide variety of inputs" do
        items = ('aa'..'zz').to_a
        50.times do
          array1 = items.sample(200)
          array2 = items.sample(200)
          result = S.new(array1).send(method, S.new(array2))
          result.to_a.sort.should eql((array1 - array2).sort)
        end
      end
    end
  end
end