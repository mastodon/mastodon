require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  describe "#product" do
    [
      [[], 1],
      [[2], 2],
      [[1, 3, 5, 7, 11], 1155],
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:set) { S[*values] }

        it "returns #{expected.inspect}" do
          set.product.should == expected
        end

        it "doesn't change the original Set" do
          set.should eql(S.new(values))
        end
      end
    end
  end
end