require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#min" do
    context "with a block" do
      [
        [[], nil],
        [["A"], "A"],
        [%w[Ichi Ni San], "Ni"],
      ].each do |values, expected|
        describe "on #{values.inspect}" do
          it "returns #{expected.inspect}" do
            V[*values].min { |minimum, item| minimum.length <=> item.length }.should == expected
          end
        end
      end
    end

    context "without a block" do
      [
        [[], nil],
        [["A"], "A"],
        [%w[Ichi Ni San], "Ichi"],
      ].each do |values, expected|
        describe "on #{values.inspect}" do
          it "returns #{expected.inspect}" do
            V[*values].min.should == expected
          end
        end
      end
    end
  end
end