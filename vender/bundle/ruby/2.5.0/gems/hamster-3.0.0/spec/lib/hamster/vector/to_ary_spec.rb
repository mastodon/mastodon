require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  let(:vector) { V[*values] }

  describe "#to_ary" do
    let(:values) { %w[A B C D] }

    it "converts using block parameters" do
      def expectations(&block)
        yield(vector)
      end
      expectations do |a, b, *c|
        expect(a).to eq("A")
        expect(b).to eq("B")
        expect(c).to eq(%w[C D])
      end
    end

    it "converts using method arguments" do
      def expectations(a, b, *c)
        expect(a).to eq("A")
        expect(b).to eq("B")
        expect(c).to eq(%w[C D])
      end
      expectations(*vector)
    end

    it "converts using splat" do
      array = *vector
      expect(array).to eq(%w[A B C D])
    end
  end
end
