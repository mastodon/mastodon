require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#empty?" do
    [
      [[], true],
      [["A"], false],
      [%w[A B C], false],
    ].each do |values, expected|
      describe "on #{values.inspect}" do
        it "returns #{expected.inspect}" do
          V[*values].empty?.should == expected
        end
      end
    end
  end

  describe ".empty" do
    it "returns the canonical empty vector" do
      V.empty.size.should be(0)
      V.empty.object_id.should be(V.empty.object_id)
    end

    context "from a subclass" do
      it "returns an empty instance of the subclass" do
        subclass = Class.new(Hamster::Vector)
        subclass.empty.class.should be(subclass)
        subclass.empty.should be_empty
      end

      it "calls overridden #initialize when creating empty Hash" do
        subclass = Class.new(Hamster::Vector) do
          def initialize
            @variable = 'value'
          end
        end
        subclass.empty.instance_variable_get(:@variable).should == 'value'
      end
    end
  end
end