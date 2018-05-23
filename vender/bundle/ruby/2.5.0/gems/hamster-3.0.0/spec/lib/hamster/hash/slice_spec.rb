require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  let(:hash) { H.new("A" => "aye", "B" => "bee", "C" => "see", nil => "NIL") }

  describe "#slice" do
    let(:slice) { hash.slice(*values) }

    context "with all keys present in the Hash" do
      let(:values) { ["B", nil] }

      it "returns the sliced values" do
        expect(slice).to eq(described_class.new("B" => "bee", nil => "NIL"))
      end

      it "doesn't modify the original Hash" do
        slice
        hash.should eql(H.new("A" => "aye", "B" => "bee", "C" => "see", nil => "NIL"))
      end
    end

    context "with keys aren't present in the Hash" do
      let(:values) { ["B", "A", 3] }

      it "returns the sliced values of the matching keys" do
        expect(slice).to eq(described_class.new("A" => "aye", "B" => "bee"))
      end

      it "doesn't modify the original Hash" do
        slice
        hash.should eql(H.new("A" => "aye", "B" => "bee", "C" => "see", nil => "NIL"))
      end
    end

    context "on a Hash with a default block" do
      let(:hash) { H.new('A' => 'aye', 'B' => 'bee') { 'nothing' }}
      let(:values) { ["B", nil] }

      it "maintains the default block" do
        expect(slice['C']).to eq('nothing')
      end
    end
  end
end
