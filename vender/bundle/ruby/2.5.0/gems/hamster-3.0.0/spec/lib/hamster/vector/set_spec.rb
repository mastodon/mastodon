require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do

  # Note: Vector#set will be deprecated; use Vector#put instead. See
  # `spec/lib/hamster/vector/put_spec.rb` for the full specs of Vector#put.

  describe "#set" do
    let(:vector) { V[5, 6, 7] }

    context "without block" do
      it "replaces the element" do
        result = vector.set(1, 100)
        result.should eql(V[5, 100, 7])
      end
    end

    context "with block" do
      it "passes the existing element to the block and replaces the result" do
        result = vector.set(1) { |e| e + 100 }
        result.should eql(V[5, 106, 7])
      end
    end
  end
end
