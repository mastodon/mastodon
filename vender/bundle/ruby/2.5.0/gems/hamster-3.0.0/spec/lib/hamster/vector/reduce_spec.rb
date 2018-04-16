require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  [:reduce, :inject].each do |method|
    describe "##{method}" do
      [
        [[], 10, 10],
        [[1], 10, 9],
        [[1, 2, 3], 10, 4],
      ].each do |values, initial, expected|
        describe "on #{values.inspect}" do
          let(:vector) { V[*values] }

          describe "with an initial value of #{initial}" do
            describe "and a block" do
              it "returns #{expected.inspect}" do
                vector.send(method, initial) { |memo, item| memo - item }.should == expected
              end
            end
          end
        end
      end

      [
        [[], nil],
        [[1], 1],
        [[1, 2, 3], -4],
      ].each do |values, expected|
        describe "on #{values.inspect}" do
          let(:vector) { V[*values] }

          describe "with no initial value" do
            describe "and a block" do
              it "returns #{expected.inspect}" do
                vector.send(method) { |memo, item| memo - item }.should == expected
              end
            end
          end
        end
      end

      describe "with no block and a symbol argument" do
        it "uses the symbol as the name of a method to reduce with" do
          V[1, 2, 3].send(method, :+).should == 6
        end
      end

      describe "with no block and a string argument" do
        it "uses the string as the name of a method to reduce with" do
          V[1, 2, 3].send(method, '+').should == 6
        end
      end
    end
  end
end