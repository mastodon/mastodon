require "spec_helper"
require "hamster/hash"
require "hamster/vector"

describe Hamster::Associable do
  describe "#update_in" do
    let(:hash) {
      Hamster::Hash[
        "A" => "aye",
        "B" => Hamster::Hash["C" => "see", "D" => Hamster::Hash["E" => "eee"]],
        "F" => Hamster::Vector["G", Hamster::Hash["H" => "eitch"], "I"]
      ]
    }
    let(:vector) {
      Hamster::Vector[
        100,
        101,
        102,
        Hamster::Vector[200, 201, Hamster::Vector[300, 301, 302]],
        Hamster::Hash["A" => "alpha", "B" => "bravo"],
        [400, 401, 402]
      ]
    }
    context "with one level on existing key" do
      it "Hash passes the value to the block" do
        hash.update_in("A") { |value| value.should == "aye" }
      end

      it "Vector passes the value to the block" do
        vector.update_in(1) { |value| value.should == 101 }
      end

      it "Hash replaces the value with the result of the block" do
        result = hash.update_in("A") { |value| "FLIBBLE" }
        result.get("A").should == "FLIBBLE"
      end

      it "Vector replaces the value with the result of the block" do
        result = vector.update_in(1) { |value| "FLIBBLE" }
        result.get(1).should == "FLIBBLE"
      end

      it "Hash should preserve the original" do
        result = hash.update_in("A") { |value| "FLIBBLE" }
        hash.get("A").should == "aye"
      end

      it "Vector should preserve the original" do
        result = vector.update_in(1) { |value| "FLIBBLE" }
        vector.get(1).should == 101
      end
    end

    context "with multi-level on existing keys" do
      it "Hash passes the value to the block" do
        hash.update_in("B", "D", "E") { |value| value.should == "eee" }
      end

      it "Vector passes the value to the block" do
        vector.update_in(3, 2, 0) { |value| value.should == 300 }
      end

      it "Hash replaces the value with the result of the block" do
        result = hash.update_in("B", "D", "E") { |value| "FLIBBLE" }
        result["B"]["D"]["E"].should == "FLIBBLE"
      end

      it "Vector replaces the value with the result of the block" do
        result = vector.update_in(3, 2, 0) { |value| "FLIBBLE" }
        result[3][2][0].should == "FLIBBLE"
      end

      it "Hash should preserve the original" do
        result = hash.update_in("B", "D", "E") { |value| "FLIBBLE" }
        hash["B"]["D"]["E"].should == "eee"
      end

      it "Vector should preserve the original" do
        result = vector.update_in(3, 2, 0) { |value| "FLIBBLE" }
        vector[3][2][0].should == 300
      end

    end

    context "with multi-level creating sub-hashes when keys don't exist" do
      it "Hash passes nil to the block" do
        hash.update_in("B", "X", "Y") { |value| value.should be_nil }
      end

      it "Vector passes nil to the block" do
        vector.update_in(3, 3, "X", "Y") { |value| value.should be_nil }
      end

      it "Hash creates subhashes on the way to set the value" do
        result = hash.update_in("B", "X", "Y") { |value| "NEWVALUE" }
        result["B"]["X"]["Y"].should == "NEWVALUE"
        result["B"]["D"]["E"].should == "eee"
      end

      it "Vector creates subhashes on the way to set the value" do
        result = vector.update_in(3, 3, "X", "Y") { |value| "NEWVALUE" }
        result[3][3]["X"]["Y"].should == "NEWVALUE"
        result[3][2][0].should == 300
      end
    end

    context "Hash with multi-level including Vector with existing keys" do
      it "passes the value to the block" do
        hash.update_in("F", 1, "H") { |value| value.should == "eitch" }
      end

      it "replaces the value with the result of the block" do
        result = hash.update_in("F", 1, "H") { |value| "FLIBBLE" }
        result["F"][1]["H"].should == "FLIBBLE"
      end

      it "should preserve the original" do
        result = hash.update_in("F", 1, "H") { |value| "FLIBBLE" }
        hash["F"][1]["H"].should == "eitch"
      end
    end

    context "Vector with multi-level including Hash with existing keys" do
      it "passes the value to the block" do
        vector.update_in(4, "B") { |value| value.should == "bravo" }
      end

      it "replaces the value with the result of the block" do
        result = vector.update_in(4, "B") { |value| "FLIBBLE" }
        result[4]["B"].should == "FLIBBLE"
      end

      it "should preserve the original" do
        result = vector.update_in(4, "B") { |value| "FLIBBLE" }
        vector[4]["B"].should == "bravo"
      end
    end

    context "with empty key_path" do
      it "Hash raises ArguemntError" do
        expect { hash.update_in() { |v| 42 } }.to raise_error(ArgumentError)
      end

      it "Vector raises ArguemntError" do
        expect { vector.update_in() { |v| 42 } }.to raise_error(ArgumentError)
      end

    end
  end
end
