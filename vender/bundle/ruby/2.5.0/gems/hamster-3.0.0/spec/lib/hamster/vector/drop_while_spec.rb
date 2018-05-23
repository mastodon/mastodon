require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#drop_while" do
    [
      [[], []],
      [["A"], []],
      [%w[A B C], ["C"]],
    ].each do |values, expected|
      describe "on #{values.inspect}" do
        let(:vector) { V[*values] }

        describe "with a block" do
          let(:result) { vector.drop_while { |item| item < "C" } }

          it "preserves the original" do
            result
            vector.should eql(V[*values])
          end

          it "returns #{expected.inspect}" do
            result.should eql(V[*expected])
          end
        end

        describe "without a block" do
          it "returns an Enumerator" do
            vector.drop_while.class.should be(Enumerator)
            vector.drop_while.each { |item| item < "C" }.should eql(V[*expected])
          end
        end
      end
    end

    context "on an empty vector" do
      it "returns an empty vector" do
        V.empty.drop_while { false }.should eql(V.empty)
      end
    end

    it "returns an empty vector if block is always true" do
      V.new(1..32).drop_while { true }.should eql(V.empty)
      V.new(1..100).drop_while { true }.should eql(V.empty)
    end

    it "stops dropping items if block returns nil" do
      V[1, 2, 3, nil, 4, 5].drop_while { |x| x }.should eql(V[nil, 4, 5])
    end

    it "stops dropping items if block returns false" do
      V[1, 2, 3, false, 4, 5].drop_while { |x| x }.should eql(V[false, 4, 5])
    end
  end
end