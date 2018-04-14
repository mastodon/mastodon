require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  let(:hash) { H["A" => "aye", "B" => "bee", "C" => "see"] }

  describe "#eql?" do
    it "returns false when comparing with a standard hash" do
      hash.eql?("A" => "aye", "B" => "bee", "C" => "see").should == false
    end

    it "returns false when comparing with an arbitrary object" do
      hash.eql?(Object.new).should == false
    end

    it "returns false when comparing with a subclass of Hamster::Hash" do
      subclass = Class.new(Hamster::Hash)
      instance = subclass.new("A" => "aye", "B" => "bee", "C" => "see")
      hash.eql?(instance).should == false
    end
  end

  describe "#==" do
    it "returns true when comparing with a standard hash" do
      (hash == {"A" => "aye", "B" => "bee", "C" => "see"}).should == true
    end

    it "returns false when comparing with an arbitrary object" do
      (hash == Object.new).should == false
    end

    it "returns true when comparing with a subclass of Hamster::Hash" do
      subclass = Class.new(Hamster::Hash)
      instance = subclass.new("A" => "aye", "B" => "bee", "C" => "see")
      (hash == instance).should == true
    end
  end

  [:eql?, :==].each do |method|
    describe "##{method}" do
      [
        [{}, {}, true],
        [{ "A" => "aye" }, {}, false],
        [{}, { "A" => "aye" }, false],
        [{ "A" => "aye" }, { "A" => "aye" }, true],
        [{ "A" => "aye" }, { "B" => "bee" }, false],
        [{ "A" => "aye", "B" => "bee" }, { "A" => "aye" }, false],
        [{ "A" => "aye" }, { "A" => "aye", "B" => "bee" }, false],
        [{ "A" => "aye", "B" => "bee", "C" => "see" }, { "A" => "aye", "B" => "bee", "C" => "see" }, true],
        [{ "C" => "see", "A" => "aye", "B" => "bee" }, { "A" => "aye", "B" => "bee", "C" => "see" }, true],
      ].each do |a, b, expected|
        describe "returns #{expected.inspect}" do
          it "for #{a.inspect} and #{b.inspect}" do
            H[a].send(method, H[b]).should == expected
          end

          it "for #{b.inspect} and #{a.inspect}" do
            H[b].send(method, H[a]).should == expected
          end
        end
      end
    end
  end

  it "returns true on a large hash which is modified and then modified back again" do
    hash = H.new((1..1000).zip(2..1001))
    hash.put('a', 1).delete('a').should == hash
    hash.put('b', 2).delete('b').should eql(hash)
  end
end