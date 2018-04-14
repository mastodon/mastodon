require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  describe "#flatten" do
    context "with flatten depth of zero" do
      it "returns a vector of keys/value" do
        hash = H[a: 1, b: 2]
        hash.flatten(0).sort.should eql(V[[:a, 1], [:b, 2]])
      end
    end

    context "without array keys or values" do
      it "returns a vector of keys and values" do
        hash = H[a: 1, b: 2, c: 3]
        possibilities = [[:a, 1, :b, 2, :c, 3],
         [:a, 1, :c, 3, :b, 2],
         [:b, 2, :a, 1, :c, 3],
         [:b, 2, :c, 3, :a, 1],
         [:c, 3, :a, 1, :b, 2],
         [:c, 3, :b, 2, :a, 1]]
        possibilities.include?(hash.flatten).should == true
        possibilities.include?(hash.flatten(1)).should == true
        possibilities.include?(hash.flatten(2)).should == true
        hash.flatten(2).class.should be(Hamster::Vector)
        possibilities.include?(hash.flatten(10)).should == true
      end

      it "doesn't modify the receiver" do
        hash = H[a: 1, b: 2, c: 3]
        hash.flatten(1)
        hash.flatten(2)
        hash.should eql(H[a: 1, b: 2, c: 3])
      end
    end

    context "on an empty Hash" do
      it "returns an empty Vector" do
        H.empty.flatten.should eql(V.empty)
      end
    end

    context "with array keys" do
      it "flattens array keys into returned vector if flatten depth is sufficient" do
        hash = H[[1, 2] => 3, [4, 5] => 6]
        [[[1, 2], 3, [4, 5], 6], [[4, 5], 6, [1, 2], 3]].include?(hash.flatten(1)).should == true
        [[[1, 2], 3, [4, 5], 6], [[4, 5], 6, [1, 2], 3]].include?(hash.flatten).should == true
        hash.flatten(1).class.should be(Hamster::Vector)
        [[1, 2, 3, 4, 5, 6], [4, 5, 6, 1, 2, 3]].include?(hash.flatten(2)).should == true
        [[1, 2, 3, 4, 5, 6], [4, 5, 6, 1, 2, 3]].include?(hash.flatten(3)).should == true
      end

      it "doesn't modify the receiver (or its contents)" do
        hash = H[[1, 2] => 3, [4, 5] => 6]
        hash.flatten(1)
        hash.flatten(2)
        hash.should eql(H[[1, 2] => 3, [4, 5] => 6])
      end
    end

    context "with array values" do
      it "flattens array values into returned vector if flatten depth is sufficient" do
        hash = H[1 => [2, 3], 4 => [5, 6]]
        [[1, [2, 3], 4, [5, 6]], [4, [5, 6], 1, [2, 3]]].include?(hash.flatten(1)).should == true
        [[1, [2, 3], 4, [5, 6]], [4, [5, 6], 1, [2, 3]]].include?(hash.flatten).should == true
        [[1, 2, 3, 4, 5, 6], [4, 5, 6, 1, 2, 3]].include?(hash.flatten(2)).should == true
        [[1, 2, 3, 4, 5, 6], [4, 5, 6, 1, 2, 3]].include?(hash.flatten(3)).should == true
        hash.flatten(3).class.should be(Hamster::Vector)
      end

      it "doesn't modify the receiver (or its contents)" do
        hash = H[1 => [2, 3], 4 => [5, 6]]
        hash.flatten(1)
        hash.flatten(2)
        hash.should eql(H[1 => [2, 3], 4 => [5, 6]])
      end
    end

    context "with vector keys" do
      it "flattens vector keys into returned vector if flatten depth is sufficient" do
        hash = H[V[1, 2] => 3, V[4, 5] => 6]
        [[V[1, 2], 3, V[4, 5], 6], [V[4, 5], 6, V[1, 2], 3]].include?(hash.flatten).should == true
        [[V[1, 2], 3, V[4, 5], 6], [V[4, 5], 6, V[1, 2], 3]].include?(hash.flatten(1)).should == true
        [[1, 2, 3, 4, 5, 6], [4, 5, 6, 1, 2, 3]].include?(hash.flatten(2)).should == true
        [[1, 2, 3, 4, 5, 6], [4, 5, 6, 1, 2, 3]].include?(hash.flatten(3)).should == true
      end
    end

    context "with vector values" do
      it "flattens vector values into returned vector if flatten depth is sufficient" do
        hash = H[1 => V[2, 3], 4 => V[5, 6]]
        [[1, V[2, 3], 4, V[5, 6]], [4, V[5, 6], 1, V[2, 3]]].include?(hash.flatten(1)).should == true
        [[1, V[2, 3], 4, V[5, 6]], [4, V[5, 6], 1, V[2, 3]]].include?(hash.flatten).should == true
        [[1, 2, 3, 4, 5, 6], [4, 5, 6, 1, 2, 3]].include?(hash.flatten(2)).should == true
        [[1, 2, 3, 4, 5, 6], [4, 5, 6, 1, 2, 3]].include?(hash.flatten(3)).should == true
      end
    end
  end
end