require "spec_helper"
require "hamster/immutable"

describe Hamster::Immutable do
  class TransformPerson < Struct.new(:first, :last)
    include Hamster::Immutable

    public :transform
  end

  let(:immutable) { TransformPerson.new("Simon", "Harris") }

  describe "#transform" do
    let(:transform) { immutable.transform { self.first = "Sampy" } }
    let(:original) { immutable.first }
    let(:modified) { transform.first }

    it "preserves the original" do
      expect(original).to eq("Simon")
    end

    it "returns a new instance with the updated values" do
      expect(modified).to eq("Sampy")
    end
  end
end
