require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  [:find_index, :index].each do |method|
    describe "##{method}" do
      [
        [[], "A", nil],
        [[], nil, nil],
        [["A"], "A", 0],
        [["A"], "B", nil],
        [["A"], nil, nil],
        [["A", "B", "C"], "A", 0],
        [["A", "B", "C"], "B", 1],
        [["A", "B", "C"], "C", 2],
        [["A", "B", "C"], "D", nil],
        [0..1, 1, 1],
        [0..10, 5, 5],
        [0..10, 10, 10],
        [[2], 2, 0],
        [[2], 2.0, 0],
        [[2.0], 2.0, 0],
        [[2.0], 2, 0],
      ].each do |values, item, expected|
        unless item.nil? # test breaks otherwise
          context "looking for #{item.inspect} in #{values.inspect} without block" do
            it "returns #{expected.inspect}" do
              SS[*values].send(method, item).should == expected
            end
          end
        end

        context "looking for #{item.inspect} in #{values.inspect} with block" do
          it "returns #{expected.inspect}" do
            SS[*values].send(method) { |x| x == item }.should == expected
          end
        end
      end
    end
  end
end