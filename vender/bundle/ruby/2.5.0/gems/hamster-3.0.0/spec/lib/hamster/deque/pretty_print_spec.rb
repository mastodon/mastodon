require "spec_helper"
require "hamster/deque"
require "pp"
require "stringio"

describe Hamster::Deque do
  describe "#pretty_print" do
    let(:deque) { Hamster::Deque["AAAA", "BBBB", "CCCC"] }
    let(:stringio) { StringIO.new }

    it "prints the whole Deque on one line if it fits" do
      PP.pp(deque, stringio, 80)
      stringio.string.chomp.should == 'Hamster::Deque["AAAA", "BBBB", "CCCC"]'
    end

    it "prints each item on its own line, if not" do
      PP.pp(deque, stringio, 10)
      stringio.string.chomp.should == 'Hamster::Deque[
 "AAAA",
 "BBBB",
 "CCCC"]'
    end
  end
end
