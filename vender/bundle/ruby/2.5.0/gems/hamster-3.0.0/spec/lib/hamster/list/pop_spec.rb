require "spec_helper"
require "hamster/list"

describe Hamster::List do
  let(:list) { L[*values] }

  describe "#pop" do
    let(:pop) { list.pop }

    context "with an empty list" do
      let(:values) { [] }

      it "returns an empty list" do
        expect(pop).to eq(L.empty)
      end
    end

    context "with a list with a few items" do
      let(:values) { %w[a b c] }

      it "removes the last item" do
        expect(pop).to eq(L["a", "b"])
      end
    end
  end
end
