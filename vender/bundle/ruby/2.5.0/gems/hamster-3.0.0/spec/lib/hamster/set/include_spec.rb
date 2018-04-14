require "spec_helper"
require "hamster/set"
require 'set'

describe Hamster::Set do
  [:include?, :member?].each do |method|
    describe "##{method}" do
      let(:set) { S["A", "B", "C", 2.0, nil] }

      ["A", "B", "C", 2.0, nil].each do |value|
        it "returns true for an existing value (#{value.inspect})" do
          set.send(method, value).should == true
        end
      end

      it "returns false for a non-existing value" do
        set.send(method, "D").should == false
      end

      it "returns true even if existing value is nil" do
        S[nil].include?(nil).should == true
      end

      it "returns true even if existing value is false" do
        S[false].include?(false).should == true
      end

      it "returns false for a mutable item which is mutated after adding" do
        item = ['mutable']
        item = [rand(1000000)] while (item.hash.abs & 31 == [item[0], 'HOSED!'].hash.abs & 31)
        set  = S[item]
        item.push('HOSED!')
        set.include?(item).should == false
      end

      it "uses #eql? for equality" do
        set.send(method, 2).should == false
      end

      it "returns the right answers after a lot of addings and removings" do
        array, set, rb_set = [], S.new, ::Set.new

        1000.times do
          if rand(2) == 0
            array << (item = rand(10000))
            rb_set.add(item)
            set = set.add(item)
            set.include?(item).should == true
          else
            item = array.sample
            rb_set.delete(item)
            set = set.delete(item)
            set.include?(item).should == false
          end
        end

        array.each { |item| set.include?(item).should == rb_set.include?(item) }
      end
    end
  end
end