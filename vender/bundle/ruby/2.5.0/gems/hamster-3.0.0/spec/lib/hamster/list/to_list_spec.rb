require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#to_list" do
    [
      [],
      ["A"],
      %w[A B C],
    ].each do |values|
      context "on #{values.inspect}" do
        let(:list) { L[*values] }

        it "returns self" do
          list.to_list.should equal(list)
        end
      end
    end
  end
end