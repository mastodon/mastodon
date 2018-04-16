require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  let(:set) { S[*values] }

  describe "#grep_v" do
    let(:grep_v) { set.grep_v(String, &block) }

    shared_examples "check filtered values" do
      it "returns the filtered values" do
        expect(grep_v).to eq(S[*filtered])
      end
    end

    context "without a block" do
      let(:block) { nil }

      context "with an empty set" do
        let(:values) { [] }
        let(:filtered) { [] }

        include_examples "check filtered values"
      end

      context "with a single item set" do
        let(:values) { ["A"] }
        let(:filtered) { [] }

        include_examples "check filtered values"
      end

      context "with a single item set that doesn't contain match" do
        let(:values) { [1] }
        let(:filtered) { [1] }

        include_examples "check filtered values"
      end

      context "with a multi-item set where one isn't a match" do
        let(:values) { [2, "C", 4] }
        let(:filtered) { [2, 4] }

        include_examples "check filtered values"
      end
    end

    describe "with a block" do
      let(:block) { ->(item) { item + 100 }}

      context "resulting items are processed with the block" do
        let(:values) { [2, "C", 4] }
        let(:filtered) { [102, 104] }

        include_examples "check filtered values"
      end
    end
  end
end
