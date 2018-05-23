require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  describe "#dig" do
    let(:h) { H[:a => 9, :b => H[:c => 'a', :d => 4], :e => nil] }
    it "returns the value with one argument to dig" do
      expect(h.dig(:a)).to eq(9)
    end

    it "returns the value in nested hashes" do
      expect(h.dig(:b, :c)).to eq('a')
    end

    it "returns nil if the key is not present" do
      expect(h.dig(:f, :foo)).to eq(nil)
    end

    it "returns nil if you dig out the end of the hash" do
      expect(h.dig(:f, :foo, :bar)).to eq(nil)
    end

    it "returns nil if a value does not support dig" do
      expect(h.dig(:a, :foo)).to eq(nil)
    end

    it "returns the correct value when there is a default proc" do
      default_hash = H.new { |k| "#{k}-default" }
      expect(default_hash.dig(:a)).to eq("a-default")
    end
  end
end
