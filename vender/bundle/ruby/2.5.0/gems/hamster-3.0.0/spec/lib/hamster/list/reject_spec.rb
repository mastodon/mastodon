require "spec_helper"
require "hamster/list"

describe Hamster::List do
  [:reject, :delete_if].each do |method|
    describe "##{method}" do
      it "is lazy" do
        -> { Hamster.stream { fail }.send(method) { |item| false } }.should_not raise_error
      end

      [
        [[], []],
        [["A"], ["A"]],
        [%w[A B C], %w[A B C]],
        [%w[A b C], %w[A C]],
        [%w[a b c], []],
      ].each do |values, expected|
        context "on #{values.inspect}" do
          let(:list) { L[*values] }

          context "with a block" do
            it "returns #{expected.inspect}" do
              list.send(method) { |item| item == item.downcase }.should eql(L[*expected])
            end

            it "is lazy" do
              count = 0
              list.send(method) do |item|
                count += 1
                false
              end
              count.should <= 1
            end
          end

          context "without a block" do
            it "returns an Enumerator" do
              list.send(method).class.should be(Enumerator)
              list.send(method).each { |item| item == item.downcase }.should eql(L[*expected])
            end
          end
        end
      end
    end
  end
end