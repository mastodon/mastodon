require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  [:group_by, :group, :classify].each do |method|
    describe "##{method}" do
      context "with a block" do
        [
          [[], []],
          [[1], [true => SS[1]]],
          [[1, 2, 3, 4], [true => SS[3, 1], false => SS[4, 2]]],
        ].each do |values, expected|
          context "on #{values.inspect}" do
            let(:sorted_set) { SS[*values] }

            it "preserves the original" do
              sorted_set.send(method, &:odd?)
              sorted_set.should eql(SS[*values])
            end

            it "returns #{expected.inspect}" do
              sorted_set.send(method, &:odd?).should eql(H[*expected])
            end
          end
        end
      end

      context "without a block" do
        [
          [[], []],
          [[1], [1 => SS[1]]],
          [[1, 2, 3, 4], [1 => SS[1], 2 => SS[2], 3 => SS[3], 4 => SS[4]]],
        ].each do |values, expected|
          context "on #{values.inspect}" do
            let(:sorted_set) { SS[*values] }

            it "preserves the original" do
              sorted_set.group_by
              sorted_set.should eql(SS[*values])
            end

            it "returns #{expected.inspect}" do
              sorted_set.group_by.should eql(H[*expected])
            end
          end
        end
      end

      context "from a subclass" do
        it "returns an Hash whose values are instances of the subclass" do
          subclass = Class.new(Hamster::SortedSet)
          instance = subclass.new(['some', 'strings', 'here'])
          instance.group_by { |x| x }.values.each { |v| v.class.should be(subclass) }
        end
      end
    end
  end
end