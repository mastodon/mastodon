require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  [:reject, :delete_if].each do |method|
    describe "##{method}" do
      [
        [[], []],
        [["A"], ["A"]],
        [%w[A B C], %w[A B C]],
        [%w[A b C], %w[A C]],
        [%w[a b c], []],
      ].each do |values, expected|
        describe "on #{values.inspect}" do
          let(:vector) { V[*values] }

          context "with a block" do
            it "returns #{expected.inspect}" do
              vector.send(method) { |item| item == item.downcase }.should eql(V[*expected])
            end
          end

          context "without a block" do
            it "returns an Enumerator" do
              vector.send(method).class.should be(Enumerator)
              vector.send(method).each { |item| item == item.downcase }.should eql(V[*expected])
            end
          end
        end
      end

      it "works with a variety of inputs" do
        [1, 2, 10, 31, 32, 33, 1023, 1024, 1025].each do |size|
          [0, 5, 32, 50, 500, 800, 1024].each do |threshold|
            vector = V.new(1..size)
            result = vector.send(method) { |item| item > threshold }
            result.size.should == [size, threshold].min
            result.should eql(V.new(1..[size, threshold].min))
          end
        end
      end
    end
  end
end