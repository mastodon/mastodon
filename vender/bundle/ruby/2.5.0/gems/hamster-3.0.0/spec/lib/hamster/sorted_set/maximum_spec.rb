require "spec_helper"
require "hamster/set"

describe Hamster::SortedSet do
  describe "#max" do
    context "with a block" do
      [
        [[], nil],
        [["A"], "A"],
        [%w[Ichi Ni San], "Ichi"],
      ].each do |values, expected|
        describe "on #{values.inspect}" do
          let(:set) { SS[*values] }
          let(:result) { set.max { |maximum, item| maximum.length <=> item.length }}

          it "returns #{expected.inspect}" do
            result.should == expected
          end
        end
      end
    end

    context "without a block" do
      [
        [[], nil],
        [["A"], "A"],
        [%w[Ichi Ni San], "San"],
      ].each do |values, expected|
        describe "on #{values.inspect}" do
          it "returns #{expected.inspect}" do
            SS[*values].max.should == expected
          end
        end
      end
    end
  end
end