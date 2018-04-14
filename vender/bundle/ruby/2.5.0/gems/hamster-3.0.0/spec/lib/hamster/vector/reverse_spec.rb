require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#reverse" do
    [
      [[], []],
      [[1], [1]],
      [[1,2], [2,1]],
      [(1..32).to_a, (1..32).to_a.reverse],
      [(1..33).to_a, (1..33).to_a.reverse],
      [(1..100).to_a, (1..100).to_a.reverse],
      [(1..1024).to_a, (1..1024).to_a.reverse]
    ].each do |initial, expected|
      describe "on #{initial}" do
        it "returns #{expected}" do
          V.new(initial).reverse.should eql(V.new(expected))
        end
      end
    end
  end
end