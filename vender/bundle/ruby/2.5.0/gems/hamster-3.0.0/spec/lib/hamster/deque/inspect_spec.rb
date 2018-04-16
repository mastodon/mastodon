require "spec_helper"
require "hamster/deque"

describe Hamster::Deque do
  describe "#inspect" do
    [
      [[], 'Hamster::Deque[]'],
      [["A"], 'Hamster::Deque["A"]'],
      [%w[A B C], 'Hamster::Deque["A", "B", "C"]']
    ].each do |values, expected|
      context "on #{values.inspect}" do
        let(:deque) { D[*values] }

        it "returns #{expected.inspect}" do
          deque.inspect.should == expected
        end

        it "returns a string which can be eval'd to get an equivalent object" do
          eval(deque.inspect).should eql(deque)
        end
      end
    end
  end
end