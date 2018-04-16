require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  let(:vector) { V[*values] }

  describe "#any?" do
    let(:any?) { vector.any?(&block) }

    context "when created with no values" do
      let(:values) { [] }

      context "with a block" do
        let(:block) { ->(item) { item + 1 } }

        it "returns false" do
          expect(any?).to be(false)
        end
      end

      context "with a block" do
        let(:block) { nil }

        it "returns false" do
          expect(any?).to be(false)
        end
      end
    end

    context "when created with values" do
      let(:values) { ["A", "B", 3, nil] }

      context "with a block that returns true" do
        let(:block) { ->(item) { item == 3 } }

        it "returns true" do
          expect(any?).to be(true)
        end
      end

      context "with a block that doesn't return true" do
        let(:block) { ->(item) { item == "D" } }

        it "returns false" do
          expect(any?).to be(false)
        end
      end

      context "without a block" do
        let(:block) { nil }

        context "with some values that are truthy" do
          let(:values) { [nil, false, "B"] }

          it "returns true" do
            expect(any?).to be(true)
          end
        end

        context "with all values that are falsey" do
          let(:values) { [nil, false] }

          it "returns false" do
            expect(any?).to be(false)
          end
        end
      end
    end
  end
end
