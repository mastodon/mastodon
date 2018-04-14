require "spec_helper"
require "hamster/set"
require "hamster/list"

describe Hamster::Set do
  describe "#to_list" do
    [
      [],
      ["A"],
      %w[A B C],
    ].each do |values|
      context "on #{values.inspect}" do
        let(:set) { S[*values] }
        let(:list) { set.to_list }

        it "returns a list" do
          list.is_a?(Hamster::List).should == true
        end

        it "doesn't change the original Set" do
          list
          set.should eql(S.new(values))
        end

        describe "the returned list" do
          it "has the correct length" do
            list.size.should == values.size
          end

          it "contains all values" do
            list.to_a.sort.should == values.sort
          end
        end
      end
    end
  end
end