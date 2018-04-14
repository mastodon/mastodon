require "spec_helper"
require "hamster/immutable"

describe Hamster::Immutable do
  class TransformUnlessPerson < Struct.new(:first, :last)
    include Hamster::Immutable

    public :transform_unless
  end

  let(:immutable) { TransformUnlessPerson.new("Simon", "Harris") }

  describe "#transform_unless" do
    let(:transform_unless) { immutable.transform_unless(condition, &block) }
    let(:original) { immutable.first }
    let(:modified) { transform_unless.first }

    context "when the condition is false" do
      let(:condition) { false }
      let(:block) { ->(thing) { self.first = "Sampy" } }

      it "preserves the original" do
        expect(original).to eq("Simon")
      end

      it "returns a new instance with the updated values" do
        expect(modified).to eq("Sampy")
      end
    end

    context "when the condition is true" do
      let(:condition) { true }
      let(:block) { -> { fail("Should never be called") } }

      it "preserves the original" do
        expect(original).to eq("Simon")
      end

      it "returns the original" do
        expect(original).to eq(modified)
      end
    end
  end
end
