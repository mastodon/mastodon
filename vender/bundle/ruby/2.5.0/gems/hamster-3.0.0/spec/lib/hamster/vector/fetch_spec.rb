require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#fetch" do
    let(:vector) { V['a', 'b', 'c'] }

    context "with no default provided" do
      context "when the index exists" do
        it "returns the value at the index" do
          vector.fetch(0).should == "a"
          vector.fetch(1).should == "b"
          vector.fetch(2).should == "c"
        end
      end

      context "when the key does not exist" do
        it "raises an IndexError" do
          -> { vector.fetch(3) }.should raise_error(IndexError)
          -> { vector.fetch(-4) }.should raise_error(IndexError)
        end
      end
    end

    context "with a default value" do
      context "when the index exists" do
        it "returns the value at the index" do
          vector.fetch(0, "default").should == "a"
          vector.fetch(1, "default").should == "b"
          vector.fetch(2, "default").should == "c"
        end
      end

      context "when the index does not exist" do
        it "returns the default value" do
          vector.fetch(3, "default").should == "default"
          vector.fetch(-4, "default").should == "default"
        end
      end
    end

    context "with a default block" do
      context "when the index exists" do
        it "returns the value at the index" do
          vector.fetch(0) { "default".upcase }.should == "a"
          vector.fetch(1) { "default".upcase }.should == "b"
          vector.fetch(2) { "default".upcase }.should == "c"
        end
      end

      context "when the index does not exist" do
        it "invokes the block with the missing index as parameter" do
          vector.fetch(3) { |index| index.should == 3}
          vector.fetch(-4) { |index| index.should == -4 }
          vector.fetch(3) { "default".upcase }.should == "DEFAULT"
          vector.fetch(-4) { "default".upcase }.should == "DEFAULT"
        end
      end
    end

    it "gives precedence to default block over default argument if passed both" do
      vector.fetch(3, 'one') { 'two' }.should == 'two'
    end
  end
end