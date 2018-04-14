require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  [:reduce, :inject].each do |method|
    describe "##{method}" do
      [
        [[], 10, 10],
        [[1], 10, 9],
        [[1, 2, 3], 10, 4],
      ].each do |values, initial, expected|
        describe "on #{values.inspect}" do
          let(:set) { S[*values] }

          context "with an initial value of #{initial}" do
            context "and a block" do
              it "returns #{expected.inspect}" do
                set.send(method, initial) { |memo, item| memo - item }.should == expected
              end
            end
          end
        end
      end

      [
        [[], nil],
        [[1], 1],
        [[1, 2, 3], 6],
      ].each do |values, expected|
        describe "on #{values.inspect}" do
          let(:set) { S[*values] }

          context "with no initial value" do
            context "and a block" do
              it "returns #{expected.inspect}" do
                set.send(method) { |memo, item| memo + item }.should == expected
              end
            end
          end
        end
      end

      describe "with no block and a symbol argument" do
        it "uses the symbol as the name of a method to reduce with" do
          S[1, 2, 3].reduce(:+).should == 6
        end
      end

      describe "with no block and a string argument" do
        it "uses the string as the name of a method to reduce with" do
          S[1, 2, 3].reduce('+').should == 6
        end
      end
    end
  end
end