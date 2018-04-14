require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  [
    [:sort, ->(left, right) { left.length <=> right.length }],
    [:sort_by, ->(item) { item.length }],
  ].each do |method, comparator|
    describe "##{method}" do
      [
        [[], []],
        [["A"], ["A"]],
        [%w[Ichi Ni San], %w[Ni San Ichi]],
      ].each do |values, expected|
        describe "on #{values.inspect}" do
          let(:sorted_set) { SS.new(values) { |item| item.reverse }}

          context "with a block" do
            it "preserves the original" do
              sorted_set.send(method, &comparator)
              sorted_set.to_a.should == SS.new(values) { |item| item.reverse }
            end

            it "returns #{expected.inspect}" do
              sorted_set.send(method, &comparator).class.should be(Hamster::SortedSet)
              sorted_set.send(method, &comparator).to_a.should == expected
            end
          end

          context "without a block" do
            it "preserves the original" do
              sorted_set.send(method)
              sorted_set.to_a.should == SS.new(values) { |item| item.reverse }
            end

            it "returns #{expected.sort.inspect}" do
              sorted_set.send(method).class.should be(Hamster::SortedSet)
              sorted_set.send(method).to_a.should == expected.sort
            end
          end
        end
      end
    end
  end
end