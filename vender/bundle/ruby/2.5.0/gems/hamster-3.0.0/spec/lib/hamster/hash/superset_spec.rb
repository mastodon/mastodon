require "spec_helper"
require "hamster/hash"

RSpec.describe Hamster::Hash do
  describe "#>=" do
    [
      [{}, {}, true],
      [{"A" => 1}, {}, true],
      [{}, {"A" => 1}, false],
      [{"A" => 1}, {"A" => 1}, true],
      [{"A" => 1}, {"A" => 2}, false],
      [{"A" => 1, "B" => 2, "C" => 3}, {"B" => 2}, true],
      [{"B" => 2}, {"A" => 1, "B" => 2, "C" => 3}, false],
      [{"A" => 1, "B" => 2, "C" => 3}, {"B" => 0}, false],
    ].each do |a, b, expected|
      describe "for #{a.inspect} and #{b.inspect}" do
        it "returns #{expected}"  do
          expect(H[a] >= H[b]).to eq(expected)
        end
      end
    end
  end

  describe "#>" do
    [
      [{}, {}, false],
      [{"A" => 1}, {}, true],
      [{}, {"A" => 1}, false],
      [{"A" => 1}, {"A" => 1}, false],
      [{"A" => 1}, {"A" => 2}, false],
      [{"A" => 1, "B" => 2, "C" => 3}, {"B" => 2}, true],
      [{"B" => 2}, {"A" => 1, "B" => 2, "C" => 3}, false],
      [{"A" => 1, "B" => 2, "C" => 3}, {"B" => 0}, false],
    ].each do |a, b, expected|
      describe "for #{a.inspect} and #{b.inspect}" do
        it "returns #{expected}"  do
          expect(H[a] > H[b]).to eq(expected)
        end
      end
    end
  end
end
