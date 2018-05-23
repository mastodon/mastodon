require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  [:get, :at].each do |method|
    describe "##{method}" do
      context "when empty" do
        it "always returns nil" do
          (-1..1).each do |i|
            V.empty.send(method, i).should be_nil
          end
        end
      end

      context "when not empty" do
        let(:vector) { V[*(1..1025)] }

        context "with a positive index" do
          context "within the absolute bounds of the vector" do
            it "returns the value at the specified index from the head" do
              (0..(vector.size - 1)).each do |i|
                vector.send(method, i).should == i + 1
              end
            end
          end

          context "outside the absolute bounds of the vector" do
            it "returns nil" do
              vector.send(method, vector.size).should be_nil
            end
          end
        end

        context "with a negative index" do
          context "within the absolute bounds of the vector" do
            it "returns the value at the specified index from the tail" do
              (-vector.size..-1).each do |i|
                vector.send(method, i).should == vector.size + i + 1
              end
            end
          end

          context "outside the absolute bounds of the vector" do
            it "returns nil" do
              vector.send(method, -vector.size.next).should be_nil
            end
          end
        end
      end

      [1, 10, 31, 32, 33, 1024, 1025, 2000].each do |size|
        context "on a #{size}-item vector" do
          it "works correctly, even after various addings and removings" do
            array = size.times.map { rand(10000) }
            vector = V.new(array)
            100.times do
              if rand(2) == 0
                value, index = rand(10000), rand(size)
                array[index] = value
                vector = vector.put(index, value)
              else
                index = rand(array.size)
                array.delete_at(index)
                vector = vector.delete_at(index)
              end
            end
            0.upto(array.size) do |i|
              array[i].should == vector.send(method, i)
            end
          end
        end
      end
    end
  end
end