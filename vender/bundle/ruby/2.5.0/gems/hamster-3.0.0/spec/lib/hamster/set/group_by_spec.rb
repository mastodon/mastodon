require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  [:group_by, :group, :classify].each do |method|
    describe "##{method}" do
      context "with a block" do
        [
          [[], []],
          [[1], [true => S[1]]],
          [[1, 2, 3, 4], [true => S[3, 1], false => S[4, 2]]],
        ].each do |values, expected|
          context "on #{values.inspect}" do
            let(:set) { S[*values] }

            it "returns #{expected.inspect}" do
              set.send(method, &:odd?).should eql(H[*expected])
              set.should eql(S.new(values)) # make sure it hasn't changed
            end
          end
        end
      end

      context "without a block" do
        [
          [[], []],
          [[1], [1 => S[1]]],
          [[1, 2, 3, 4], [1 => S[1], 2 => S[2], 3 => S[3], 4 => S[4]]],
        ].each do |values, expected|
          context "on #{values.inspect}" do
            let(:set) { S[*values] }

            it "returns #{expected.inspect}" do
              set.group_by.should eql(H[*expected])
              set.should eql(S.new(values)) # make sure it hasn't changed
            end
          end
        end
      end

      context "on an empty set" do
        it "returns an empty hash" do
          S.empty.group_by { |x| x }.should eql(H.empty)
        end
      end

      it "returns a hash without default proc" do
        S[1,2,3].group_by { |x| x }.default_proc.should be_nil
      end

      context "from a subclass" do
        it "returns an Hash whose values are instances of the subclass" do
          subclass = Class.new(Hamster::Set)
          instance = subclass.new([1, 'string', :symbol])
          instance.group_by { |x| x.class }.values.each { |v| v.class.should be(subclass) }
        end
      end
    end
  end
end