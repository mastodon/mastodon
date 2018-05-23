require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  [:dup, :clone].each do |method|
    [
      [],
      ["A"],
      %w[A B C],
      (1..32),
    ].each do |values|
      describe "on #{values.inspect}" do
        let(:vector) { V[*values] }

        it "returns self" do
          vector.send(method).should equal(vector)
        end
      end
    end
  end
end