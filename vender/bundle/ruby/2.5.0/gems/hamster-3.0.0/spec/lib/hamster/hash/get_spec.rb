require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  [:get, :[]].each do |method|
    describe "##{method}" do
      context "with a default block" do
        let(:hash) { H.new("A" => "aye") { |key| fail }}

        context "when the key exists" do
          it "returns the value associated with the key" do
            hash.send(method, "A").should == "aye"
          end

          it "does not call the default block even if the key is 'nil'" do
            H.new(nil => 'something') { fail }.send(method, nil)
          end
        end

        context "when the key does not exist" do
          let(:hash) do
            H.new("A" => "aye") do |key|
              expect(key).to eq("B")
              "bee"
            end
          end

          it "returns the value from the default block" do
            hash.send(method, "B").should == "bee"
          end
        end
      end

      context "with no default block" do
        let(:hash) { H["A" => "aye", "B" => "bee", "C" => "see", nil => "NIL"] }

        [
          %w[A aye],
          %w[B bee],
          %w[C see],
          [nil, "NIL"]
        ].each do |key, value|
          it "returns the value (#{value.inspect}) for an existing key (#{key.inspect})" do
            hash.send(method, key).should == value
          end
        end

        it "returns nil for a non-existing key" do
          hash.send(method, "D").should be_nil
        end
      end

      it "uses #hash to look up keys" do
        x = double('0')
        x.should_receive(:hash).and_return(0)
        H[foo: :bar].send(method, x).should be_nil
      end

      it "uses #eql? to compare keys with the same hash code" do
        x = double('x', hash: 42)
        x.should_not_receive(:eql?)

        y = double('y', hash: 42)
        y.should_receive(:eql?).and_return(true)

        H[y => 1][x].should == 1
      end

      it "does not use #eql? to compare keys with different hash codes" do
        x = double('x', hash: 0)
        x.should_not_receive(:eql?)

        y = double('y', hash: 1)
        y.should_not_receive(:eql?)

        H[y => 1][x].should be_nil
      end
    end
  end
end
