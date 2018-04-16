require "spec_helper"
require "hamster/set"

describe Hamster::Set do
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
          let(:set) { S[*values] }

          describe "with a block" do
            let(:result) { set.send(method, &comparator) }

            it "returns #{expected.inspect}" do
              result.should eql(SS.new(expected, &comparator))
              result.to_a.should == expected
            end

            it "doesn't change the original Set" do
              result
              set.should eql(S.new(values))
            end
          end

          describe "without a block" do
            let(:result) { set.send(method) }

            it "returns #{expected.sort.inspect}" do
              result.should eql(SS[*expected])
              result.to_a.should == expected.sort
            end

            it "doesn't change the original Set" do
              result
              set.should eql(S.new(values))
            end
          end
        end
      end
    end
  end

  describe "#sort_by" do
    it "only calls the passed block once for each item" do
      count = 0
      fn    = lambda { |x| count += 1; -x }
      items = 100.times.collect { rand(10000) }.uniq

      S[*items].sort_by(&fn).to_a.should == items.sort.reverse
      count.should == items.length
    end
  end
end