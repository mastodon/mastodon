require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  [:intersection, :&].each do |method|
    describe "##{method}" do
      [
        [[], [], []],
        [["A"], [], []],
        [["A"], ["A"], ["A"]],
        [%w[A B C], ["B"], ["B"]],
        [%w[A B C], %w[A C], %w[A C]],
      ].each do |a, b, expected|
        context "for #{a.inspect} and #{b.inspect}"  do
          let(:set_a) { S[*a] }
          let(:set_b) { S[*b] }

          it "returns #{expected.inspect}, without changing the original Sets" do
            set_a.send(method, set_b).should eql(S[*expected])
            set_a.should eql(S.new(a))
            set_b.should eql(S.new(b))
          end
        end

        context "for #{b.inspect} and #{a.inspect}"  do
          let(:set_a) { S[*a] }
          let(:set_b) { S[*b] }

          it "returns #{expected.inspect}, without changing the original Sets" do
            set_b.send(method, set_a).should eql(S[*expected])
            set_a.should eql(S.new(a))
            set_b.should eql(S.new(b))
          end
        end

        context "when passed a Ruby Array" do
          it "returns the expected Set" do
            S[*a].send(method, b.freeze).should eql(S[*expected])
          end
        end
      end

      it "returns results consistent with Array#&" do
        50.times do
          array1 = rand(100).times.map { rand(1000000).to_s(16) }
          array2 = rand(100).times.map { rand(1000000).to_s(16) }
          result = S.new(array1).send(method, S.new(array2))
          result.to_a.sort.should eql((array1 & array2).sort)
        end
      end
    end
  end
end