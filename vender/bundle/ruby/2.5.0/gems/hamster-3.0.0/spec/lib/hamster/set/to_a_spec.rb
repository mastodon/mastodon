require "spec_helper"
require "hamster/set"

describe Hamster::Set do
  [:to_a, :entries].each do |method|
    describe "##{method}" do
      ('a'..'z').each do |letter|
        let(:values) { ('a'..letter).to_a }
        let(:set) { S.new(values) }
        let(:result) { set.send(method) }

        context "on 'a'..'#{letter}'" do
          it "returns an equivalent array" do
            result.sort.should == values.sort
          end

          it "doesn't change the original Set" do
            result
            set.should eql(S[*values])
          end

          it "returns a mutable array" do
            expect(result.last).to_not eq("The End")
            result << "The End"
            result.last.should == "The End"
          end
        end
      end
    end
  end
end