require "spec_helper"
require "hamster/deque"

describe Hamster::Deque do
  let(:deque) { D["A", "B", "C", "D"] }

  describe "#to_ary" do
    context "enables implicit conversion to" do
      it "block parameters" do
        def func(&block)
          yield(deque)
        end

        func do |a, b, *c|
          expect(a).to eq("A")
          expect(b).to eq("B")
          expect(c).to eq(%w[C D])
        end
      end

      it "method arguments" do
        def func(a, b, *c)
          expect(a).to eq("A")
          expect(b).to eq("B")
          expect(c).to eq(%w[C D])
        end
        func(*deque)
      end

      it "works with splat" do
        array = *deque
        expect(array).to eq(%w[A B C D])
      end
    end
  end
end
