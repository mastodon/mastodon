require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  [:dup, :clone].each do |method|
    let(:set) { S["A", "B", "C"] }

    describe "##{method}" do
      it "returns self" do
        set.send(method).should equal(set)
      end
    end
  end
end