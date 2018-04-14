require "spec_helper"
require "hamster/list"

describe Hamster::List do
  describe "#clear" do
    [
      [],
      ["A"],
      %w[A B C],
    ].each do |values|
      describe "on #{values}" do
        let(:list) { L[*values] }

        it "preserves the original" do
          list.clear
          list.should eql(L[*values])
        end

        it "returns an empty list" do
          list.clear.should equal(L.empty)
        end
      end
    end
  end
end