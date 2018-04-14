require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  [:+, :concat].each do |method|
    describe "##{method}" do
      let(:vector) { V.new(1..100) }

      it "preserves the original" do
        vector.concat([1,2,3])
        vector.should eql(V.new(1..100))
      end

      it "appends the elements in the other enumerable" do
        vector.concat([1,2,3]).should eql(V.new((1..100).to_a + [1,2,3]))
        vector.concat(1..1000).should eql(V.new((1..100).to_a + (1..1000).to_a))
        vector.concat(1..200).size.should == 300
        vector.concat(vector).should eql(V.new((1..100).to_a * 2))
        vector.concat(V.empty).should eql(vector)
        V.empty.concat(vector).should eql(vector)
      end

      [1, 31, 32, 33, 1023, 1024, 1025].each do |size|
        context "on a #{size}-item vector" do
          it "works the same" do
            vector = V.new(1..size)
            result = vector.concat((size+1)..size+10)
            result.size.should == size + 10
            result.should eql(V.new(1..(size+10)))
          end
        end
      end
    end
  end
end