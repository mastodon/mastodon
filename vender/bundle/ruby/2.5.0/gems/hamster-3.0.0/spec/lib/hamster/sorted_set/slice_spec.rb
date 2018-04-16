require "spec_helper"
require "hamster/sorted_set"

describe Hamster::SortedSet do
  let(:sorted_set) { SS[1,2,3,4] }
  let(:big) { SS.new(1..10000) }

  [:slice, :[]].each do |method|
    describe "##{method}" do
      context "when passed a positive integral index" do
        it "returns the element at that index" do
          sorted_set.send(method, 0).should be(1)
          sorted_set.send(method, 1).should be(2)
          sorted_set.send(method, 2).should be(3)
          sorted_set.send(method, 3).should be(4)
          sorted_set.send(method, 4).should be(nil)
          sorted_set.send(method, 10).should be(nil)

          big.send(method, 0).should be(1)
          big.send(method, 9999).should be(10000)
        end

        it "leaves the original unchanged" do
          sorted_set.should eql(SS[1,2,3,4])
        end
      end

      context "when passed a negative integral index" do
        it "returns the element which is number (index.abs) counting from the end of the sorted_set" do
          sorted_set.send(method, -1).should be(4)
          sorted_set.send(method, -2).should be(3)
          sorted_set.send(method, -3).should be(2)
          sorted_set.send(method, -4).should be(1)
          sorted_set.send(method, -5).should be(nil)
          sorted_set.send(method, -10).should be(nil)

          big.send(method, -1).should be(10000)
          big.send(method, -10000).should be(1)
        end
      end

      context "when passed a positive integral index and count" do
        it "returns 'count' elements starting from 'index'" do
          sorted_set.send(method, 0, 0).should  eql(SS.empty)
          sorted_set.send(method, 0, 1).should  eql(SS[1])
          sorted_set.send(method, 0, 2).should  eql(SS[1,2])
          sorted_set.send(method, 0, 4).should  eql(SS[1,2,3,4])
          sorted_set.send(method, 0, 6).should  eql(SS[1,2,3,4])
          sorted_set.send(method, 0, -1).should be_nil
          sorted_set.send(method, 0, -2).should be_nil
          sorted_set.send(method, 0, -4).should be_nil
          sorted_set.send(method, 2, 0).should  eql(SS.empty)
          sorted_set.send(method, 2, 1).should  eql(SS[3])
          sorted_set.send(method, 2, 2).should  eql(SS[3,4])
          sorted_set.send(method, 2, 4).should  eql(SS[3,4])
          sorted_set.send(method, 2, -1).should be_nil
          sorted_set.send(method, 4, 0).should  eql(SS.empty)
          sorted_set.send(method, 4, 2).should  eql(SS.empty)
          sorted_set.send(method, 4, -1).should be_nil
          sorted_set.send(method, 5, 0).should  be_nil
          sorted_set.send(method, 5, 2).should  be_nil
          sorted_set.send(method, 5, -1).should be_nil
          sorted_set.send(method, 6, 0).should  be_nil
          sorted_set.send(method, 6, 2).should  be_nil
          sorted_set.send(method, 6, -1).should be_nil

          big.send(method, 0, 3).should    eql(SS[1,2,3])
          big.send(method, 1023, 4).should eql(SS[1024,1025,1026,1027])
          big.send(method, 1024, 4).should eql(SS[1025,1026,1027,1028])
        end

        it "leaves the original unchanged" do
          sorted_set.should eql(SS[1,2,3,4])
        end
      end

      context "when passed a negative integral index and count" do
        it "returns 'count' elements, starting from index which is number 'index.abs' counting from the end of the array" do
          sorted_set.send(method, -1, 0).should  eql(SS.empty)
          sorted_set.send(method, -1, 1).should  eql(SS[4])
          sorted_set.send(method, -1, 2).should  eql(SS[4])
          sorted_set.send(method, -1, -1).should be_nil
          sorted_set.send(method, -2, 0).should  eql(SS.empty)
          sorted_set.send(method, -2, 1).should  eql(SS[3])
          sorted_set.send(method, -2, 2).should  eql(SS[3,4])
          sorted_set.send(method, -2, 4).should  eql(SS[3,4])
          sorted_set.send(method, -2, -1).should be_nil
          sorted_set.send(method, -4, 0).should  eql(SS.empty)
          sorted_set.send(method, -4, 1).should  eql(SS[1])
          sorted_set.send(method, -4, 2).should  eql(SS[1,2])
          sorted_set.send(method, -4, 4).should  eql(SS[1,2,3,4])
          sorted_set.send(method, -4, 6).should  eql(SS[1,2,3,4])
          sorted_set.send(method, -4, -1).should be_nil
          sorted_set.send(method, -5, 0).should  be_nil
          sorted_set.send(method, -5, 1).should  be_nil
          sorted_set.send(method, -5, 10).should be_nil
          sorted_set.send(method, -5, -1).should be_nil

          big.send(method, -1, 1).should eql(SS[10000])
          big.send(method, -1, 2).should eql(SS[10000])
          big.send(method, -6, 2).should eql(SS[9995,9996])
        end
      end

      context "when passed a Range" do
        it "returns the elements whose indexes are within the given Range" do
          sorted_set.send(method, 0..-1).should  eql(SS[1,2,3,4])
          sorted_set.send(method, 0..-10).should eql(SS.empty)
          sorted_set.send(method, 0..0).should   eql(SS[1])
          sorted_set.send(method, 0..1).should   eql(SS[1,2])
          sorted_set.send(method, 0..2).should   eql(SS[1,2,3])
          sorted_set.send(method, 0..3).should   eql(SS[1,2,3,4])
          sorted_set.send(method, 0..4).should   eql(SS[1,2,3,4])
          sorted_set.send(method, 0..10).should  eql(SS[1,2,3,4])
          sorted_set.send(method, 2..-10).should eql(SS.empty)
          sorted_set.send(method, 2..0).should   eql(SS.empty)
          sorted_set.send(method, 2..2).should   eql(SS[3])
          sorted_set.send(method, 2..3).should   eql(SS[3,4])
          sorted_set.send(method, 2..4).should   eql(SS[3,4])
          sorted_set.send(method, 3..0).should   eql(SS.empty)
          sorted_set.send(method, 3..3).should   eql(SS[4])
          sorted_set.send(method, 3..4).should   eql(SS[4])
          sorted_set.send(method, 4..0).should   eql(SS.empty)
          sorted_set.send(method, 4..4).should   eql(SS.empty)
          sorted_set.send(method, 4..5).should   eql(SS.empty)
          sorted_set.send(method, 5..0).should   be_nil
          sorted_set.send(method, 5..5).should   be_nil
          sorted_set.send(method, 5..6).should   be_nil

          big.send(method, 159..162).should     eql(SS[160,161,162,163])
          big.send(method, 160..162).should     eql(SS[161,162,163])
          big.send(method, 161..162).should     eql(SS[162,163])
          big.send(method, 9999..10100).should  eql(SS[10000])
          big.send(method, 10000..10100).should eql(SS.empty)
          big.send(method, 10001..10100).should be_nil

          sorted_set.send(method, 0...-1).should  eql(SS[1,2,3])
          sorted_set.send(method, 0...-10).should eql(SS.empty)
          sorted_set.send(method, 0...0).should   eql(SS.empty)
          sorted_set.send(method, 0...1).should   eql(SS[1])
          sorted_set.send(method, 0...2).should   eql(SS[1,2])
          sorted_set.send(method, 0...3).should   eql(SS[1,2,3])
          sorted_set.send(method, 0...4).should   eql(SS[1,2,3,4])
          sorted_set.send(method, 0...10).should  eql(SS[1,2,3,4])
          sorted_set.send(method, 2...-10).should eql(SS.empty)
          sorted_set.send(method, 2...0).should   eql(SS.empty)
          sorted_set.send(method, 2...2).should   eql(SS.empty)
          sorted_set.send(method, 2...3).should   eql(SS[3])
          sorted_set.send(method, 2...4).should   eql(SS[3,4])
          sorted_set.send(method, 3...0).should   eql(SS.empty)
          sorted_set.send(method, 3...3).should   eql(SS.empty)
          sorted_set.send(method, 3...4).should   eql(SS[4])
          sorted_set.send(method, 4...0).should   eql(SS.empty)
          sorted_set.send(method, 4...4).should   eql(SS.empty)
          sorted_set.send(method, 4...5).should   eql(SS.empty)
          sorted_set.send(method, 5...0).should   be_nil
          sorted_set.send(method, 5...5).should   be_nil
          sorted_set.send(method, 5...6).should   be_nil

          big.send(method, 159...162).should     eql(SS[160,161,162])
          big.send(method, 160...162).should     eql(SS[161,162])
          big.send(method, 161...162).should     eql(SS[162])
          big.send(method, 9999...10100).should  eql(SS[10000])
          big.send(method, 10000...10100).should eql(SS.empty)
          big.send(method, 10001...10100).should be_nil

          sorted_set.send(method, -1..-1).should  eql(SS[4])
          sorted_set.send(method, -1...-1).should eql(SS.empty)
          sorted_set.send(method, -1..3).should   eql(SS[4])
          sorted_set.send(method, -1...3).should  eql(SS.empty)
          sorted_set.send(method, -1..4).should   eql(SS[4])
          sorted_set.send(method, -1...4).should  eql(SS[4])
          sorted_set.send(method, -1..10).should  eql(SS[4])
          sorted_set.send(method, -1...10).should eql(SS[4])
          sorted_set.send(method, -1..0).should   eql(SS.empty)
          sorted_set.send(method, -1..-4).should  eql(SS.empty)
          sorted_set.send(method, -1...-4).should eql(SS.empty)
          sorted_set.send(method, -1..-6).should  eql(SS.empty)
          sorted_set.send(method, -1...-6).should eql(SS.empty)
          sorted_set.send(method, -2..-2).should  eql(SS[3])
          sorted_set.send(method, -2...-2).should eql(SS.empty)
          sorted_set.send(method, -2..-1).should  eql(SS[3,4])
          sorted_set.send(method, -2...-1).should eql(SS[3])
          sorted_set.send(method, -2..10).should  eql(SS[3,4])
          sorted_set.send(method, -2...10).should eql(SS[3,4])

          big.send(method, -1..-1).should    eql(SS[10000])
          big.send(method, -1..9999).should  eql(SS[10000])
          big.send(method, -1...9999).should eql(SS.empty)
          big.send(method, -2...9999).should eql(SS[9999])
          big.send(method, -2..-1).should    eql(SS[9999,10000])

          sorted_set.send(method, -4..-4).should  eql(SS[1])
          sorted_set.send(method, -4..-2).should  eql(SS[1,2,3])
          sorted_set.send(method, -4...-2).should eql(SS[1,2])
          sorted_set.send(method, -4..-1).should  eql(SS[1,2,3,4])
          sorted_set.send(method, -4...-1).should eql(SS[1,2,3])
          sorted_set.send(method, -4..3).should   eql(SS[1,2,3,4])
          sorted_set.send(method, -4...3).should  eql(SS[1,2,3])
          sorted_set.send(method, -4..4).should   eql(SS[1,2,3,4])
          sorted_set.send(method, -4...4).should  eql(SS[1,2,3,4])
          sorted_set.send(method, -4..0).should   eql(SS[1])
          sorted_set.send(method, -4...0).should  eql(SS.empty)
          sorted_set.send(method, -4..1).should   eql(SS[1,2])
          sorted_set.send(method, -4...1).should  eql(SS[1])

          sorted_set.send(method, -5..-5).should  be_nil
          sorted_set.send(method, -5...-5).should be_nil
          sorted_set.send(method, -5..-4).should  be_nil
          sorted_set.send(method, -5..-1).should  be_nil
          sorted_set.send(method, -5..10).should  be_nil

          big.send(method, -10001..-1).should be_nil
        end

        it "leaves the original unchanged" do
          sorted_set.should eql(SS[1,2,3,4])
        end
      end
    end

    context "when passed an empty Range" do
      it "does not lose custom sort order" do
        ss = SS.new(["yogurt", "cake", "pistachios"]) { |word| word.length }
        ss = ss.send(method, 1...1).add("tea").add("fruitcake").add("toast")
        ss.to_a.should == ["tea", "toast", "fruitcake"]
      end
    end

    context "when passed a length of zero" do
      it "does not lose custom sort order" do
        ss = SS.new(["yogurt", "cake", "pistachios"]) { |word| word.length }
        ss = ss.send(method, 0, 0).add("tea").add("fruitcake").add("toast")
        ss.to_a.should == ["tea", "toast", "fruitcake"]
      end
    end

    context "when passed a subclass of Range" do
      it "works the same as with a Range" do
        subclass = Class.new(Range)
        sorted_set.send(method, subclass.new(1,2)).should eql(SS[2,3])
        sorted_set.send(method, subclass.new(-3,-1,true)).should eql(SS[2,3])
      end
    end

    context "on a subclass of SortedSet" do
      it "with index and count or a range, returns an instance of the subclass" do
        subclass = Class.new(Hamster::SortedSet)
        instance = subclass.new([1,2,3])
        instance.send(method, 0, 0).class.should be(subclass)
        instance.send(method, 0, 2).class.should be(subclass)
        instance.send(method, 0..0).class.should be(subclass)
        instance.send(method, 1..-1).class.should be(subclass)
      end
    end
  end
end