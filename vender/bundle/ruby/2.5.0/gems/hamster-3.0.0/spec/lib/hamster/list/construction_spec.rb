require "spec_helper"
require "hamster/list"

describe Hamster do
  describe ".list" do
    context "with no arguments" do
      it "always returns the same instance" do
        L.empty.should equal(L.empty)
      end

      it "returns an empty list" do
        L.empty.should be_empty
      end
    end

    context "with a number of items" do
      it "always returns a different instance" do
        L["A", "B", "C"].should_not equal(L["A", "B", "C"])
      end

      it "is the same as repeatedly using #cons" do
        L["A", "B", "C"].should eql(L.empty.cons("C").cons("B").cons("A"))
      end
    end
  end

  describe ".stream" do
    context "with no block" do
      it "returns an empty list" do
        Hamster.stream.should eql(L.empty)
      end
    end

    context "with a block" do
      let(:list) { count = 0; Hamster.stream { count += 1 }}

      it "repeatedly calls the block" do
        list.take(5).should eql(L[1, 2, 3, 4, 5])
      end
    end
  end

  describe ".interval" do
    context "for numbers" do
      it "is equivalent to a list with explicit values" do
        Hamster.interval(98, 102).should eql(L[98, 99, 100, 101, 102])
      end
    end

    context "for strings" do
      it "is equivalent to a list with explicit values" do
        Hamster.interval("A", "AA").should eql(L["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "AA"])
      end
    end
  end

  describe ".repeat" do
    it "returns an infinite list with specified value for each element" do
      Hamster.repeat("A").take(5).should eql(L["A", "A", "A", "A", "A"])
    end
  end

  describe ".replicate" do
    it "returns a list with the specified value repeated the specified number of times" do
      Hamster.replicate(5, "A").should eql(L["A", "A", "A", "A", "A"])
    end
  end

  describe ".iterate" do
    it "returns an infinite list where the first item is calculated by applying the block on the initial argument, the second item by applying the function on the previous result and so on" do
      Hamster.iterate(1) { |item| item * 2 }.take(10).should eql(L[1, 2, 4, 8, 16, 32, 64, 128, 256, 512])
    end
  end

  describe ".enumerate" do
    let(:enum) do
      Enumerator.new do |yielder|
        yielder << 1
        yielder << 2
        yielder << 3
        raise "list fully realized"
      end
    end

    let(:list) { Hamster.enumerate(enum) }

    it "returns a list based on the values yielded from the enumerator" do
      expect(list.take(2)).to eq L[1, 2]
    end

    it "realizes values as they are needed" do
      # this example shows that Lists are not as lazy as they could be
      # if Lists were fully lazy, you would have to take(4) to hit the exception
      expect { list.take(3).to_a }.to raise_exception
    end
  end

  describe "[]" do
    it "takes a variable number of items and returns a list" do
      list = Hamster::List[1,2,3]
      list.should be_kind_of(Hamster::List)
      list.size.should be(3)
      list.to_a.should == [1,2,3]
    end

    it "returns an empty list when called without arguments" do
      L[].should be_kind_of(Hamster::List)
      L[].should be_empty
    end
  end
end