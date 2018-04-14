require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  describe "#to_set" do
    [
      [],
      ["A"],
      %w[A B C],
    ].each do |values|
      describe "on #{values.inspect}" do
        let(:set) { S[*values] }

        it "returns self" do
          set.to_set.should equal(set)
        end
      end
    end
  end
end