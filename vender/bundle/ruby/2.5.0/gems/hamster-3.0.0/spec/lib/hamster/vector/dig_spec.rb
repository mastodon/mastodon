require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  let(:v) { V[1, 2, V[3, 4]] }

  describe "#dig" do
    it "returns value at the index with one argument" do
      expect(v.dig(0)).to eq(1)
    end

    it "returns value at index in nested arrays" do
      expect(v.dig(2, 0)).to eq(3)
    end

    it "returns nil when indexing deeper than possible" do
      expect(v.dig(0, 0)).to eq(nil)
    end

    it "returns nil if you index past the end of an array" do
      expect(v.dig(5)).to eq(nil)
    end

    it "raises a type error when indexing with a key arrays don't understand" do
      expect{ v.dig(:foo) }.to raise_error(ArgumentError)
    end
  end
end
