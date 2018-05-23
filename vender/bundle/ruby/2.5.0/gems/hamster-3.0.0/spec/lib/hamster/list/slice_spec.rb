require "spec_helper"
require "hamster/list"

describe Hamster::List do
  let(:list) { L[1,2,3,4] }
  let(:big)  { (1..10000).to_list }

  [:slice, :[]].each do |method|
    describe "##{method}" do
      context "when passed a positive integral index" do
        it "returns the element at that index" do
          list.send(method, 0).should be(1)
          list.send(method, 1).should be(2)
          list.send(method, 2).should be(3)
          list.send(method, 3).should be(4)
          list.send(method, 4).should be(nil)
          list.send(method, 10).should be(nil)

          big.send(method, 0).should be(1)
          big.send(method, 9999).should be(10000)
        end

        it "leaves the original unchanged" do
          list.should eql(L[1,2,3,4])
        end
      end

      context "when passed a negative integral index" do
        it "returns the element which is number (index.abs) counting from the end of the list" do
          list.send(method, -1).should be(4)
          list.send(method, -2).should be(3)
          list.send(method, -3).should be(2)
          list.send(method, -4).should be(1)
          list.send(method, -5).should be(nil)
          list.send(method, -10).should be(nil)

          big.send(method, -1).should be(10000)
          big.send(method, -10000).should be(1)
        end
      end

      context "when passed a positive integral index and count" do
        it "returns 'count' elements starting from 'index'" do
          list.send(method, 0, 0).should eql(L.empty)
          list.send(method, 0, 1).should eql(L[1])
          list.send(method, 0, 2).should eql(L[1,2])
          list.send(method, 0, 4).should eql(L[1,2,3,4])
          list.send(method, 0, 6).should eql(L[1,2,3,4])
          list.send(method, 0, -1).should be_nil
          list.send(method, 0, -2).should be_nil
          list.send(method, 0, -4).should be_nil
          list.send(method, 2, 0).should eql(L.empty)
          list.send(method, 2, 1).should eql(L[3])
          list.send(method, 2, 2).should eql(L[3,4])
          list.send(method, 2, 4).should eql(L[3,4])
          list.send(method, 2, -1).should be_nil
          list.send(method, 4, 0).should eql(L.empty)
          list.send(method, 4, 2).should eql(L.empty)
          list.send(method, 4, -1).should be_nil
          list.send(method, 5, 0).should be_nil
          list.send(method, 5, 2).should be_nil
          list.send(method, 5, -1).should be_nil
          list.send(method, 6, 0).should be_nil
          list.send(method, 6, 2).should be_nil
          list.send(method, 6, -1).should be_nil

          big.send(method, 0, 3).should eql(L[1,2,3])
          big.send(method, 1023, 4).should eql(L[1024,1025,1026,1027])
          big.send(method, 1024, 4).should eql(L[1025,1026,1027,1028])
        end

        it "leaves the original unchanged" do
          list.should eql(L[1,2,3,4])
        end
      end

      context "when passed a negative integral index and count" do
        it "returns 'count' elements, starting from index which is number 'index.abs' counting from the end of the array" do
          list.send(method, -1, 0).should eql(L.empty)
          list.send(method, -1, 1).should eql(L[4])
          list.send(method, -1, 2).should eql(L[4])
          list.send(method, -1, -1).should be_nil
          list.send(method, -2, 0).should eql(L.empty)
          list.send(method, -2, 1).should eql(L[3])
          list.send(method, -2, 2).should eql(L[3,4])
          list.send(method, -2, 4).should eql(L[3,4])
          list.send(method, -2, -1).should be_nil
          list.send(method, -4, 0).should eql(L.empty)
          list.send(method, -4, 1).should eql(L[1])
          list.send(method, -4, 2).should eql(L[1,2])
          list.send(method, -4, 4).should eql(L[1,2,3,4])
          list.send(method, -4, 6).should eql(L[1,2,3,4])
          list.send(method, -4, -1).should be_nil
          list.send(method, -5, 0).should be_nil
          list.send(method, -5, 1).should be_nil
          list.send(method, -5, 10).should be_nil
          list.send(method, -5, -1).should be_nil

          big.send(method, -1, 1).should eql(L[10000])
          big.send(method, -1, 2).should eql(L[10000])
          big.send(method, -6, 2).should eql(L[9995,9996])
        end
      end

      context "when passed a Range" do
        it "returns the elements whose indexes are within the given Range" do
          list.send(method, 0..-1).should eql(L[1,2,3,4])
          list.send(method, 0..-10).should eql(L.empty)
          list.send(method, 0..0).should eql(L[1])
          list.send(method, 0..1).should eql(L[1,2])
          list.send(method, 0..2).should eql(L[1,2,3])
          list.send(method, 0..3).should eql(L[1,2,3,4])
          list.send(method, 0..4).should eql(L[1,2,3,4])
          list.send(method, 0..10).should eql(L[1,2,3,4])
          list.send(method, 2..-10).should eql(L.empty)
          list.send(method, 2..0).should eql(L.empty)
          list.send(method, 2..2).should eql(L[3])
          list.send(method, 2..3).should eql(L[3,4])
          list.send(method, 2..4).should eql(L[3,4])
          list.send(method, 3..0).should eql(L.empty)
          list.send(method, 3..3).should eql(L[4])
          list.send(method, 3..4).should eql(L[4])
          list.send(method, 4..0).should eql(L.empty)
          list.send(method, 4..4).should eql(L.empty)
          list.send(method, 4..5).should eql(L.empty)
          list.send(method, 5..0).should be_nil
          list.send(method, 5..5).should be_nil
          list.send(method, 5..6).should be_nil

          big.send(method, 159..162).should eql(L[160,161,162,163])
          big.send(method, 160..162).should eql(L[161,162,163])
          big.send(method, 161..162).should eql(L[162,163])
          big.send(method, 9999..10100).should eql(L[10000])
          big.send(method, 10000..10100).should eql(L.empty)
          big.send(method, 10001..10100).should be_nil

          list.send(method, 0...-1).should eql(L[1,2,3])
          list.send(method, 0...-10).should eql(L.empty)
          list.send(method, 0...0).should eql(L.empty)
          list.send(method, 0...1).should eql(L[1])
          list.send(method, 0...2).should eql(L[1,2])
          list.send(method, 0...3).should eql(L[1,2,3])
          list.send(method, 0...4).should eql(L[1,2,3,4])
          list.send(method, 0...10).should eql(L[1,2,3,4])
          list.send(method, 2...-10).should eql(L.empty)
          list.send(method, 2...0).should eql(L.empty)
          list.send(method, 2...2).should eql(L.empty)
          list.send(method, 2...3).should eql(L[3])
          list.send(method, 2...4).should eql(L[3,4])
          list.send(method, 3...0).should eql(L.empty)
          list.send(method, 3...3).should eql(L.empty)
          list.send(method, 3...4).should eql(L[4])
          list.send(method, 4...0).should eql(L.empty)
          list.send(method, 4...4).should eql(L.empty)
          list.send(method, 4...5).should eql(L.empty)
          list.send(method, 5...0).should be_nil
          list.send(method, 5...5).should be_nil
          list.send(method, 5...6).should be_nil

          big.send(method, 159...162).should eql(L[160,161,162])
          big.send(method, 160...162).should eql(L[161,162])
          big.send(method, 161...162).should eql(L[162])
          big.send(method, 9999...10100).should eql(L[10000])
          big.send(method, 10000...10100).should eql(L.empty)
          big.send(method, 10001...10100).should be_nil

          list.send(method, -1..-1).should eql(L[4])
          list.send(method, -1...-1).should eql(L.empty)
          list.send(method, -1..3).should eql(L[4])
          list.send(method, -1...3).should eql(L.empty)
          list.send(method, -1..4).should eql(L[4])
          list.send(method, -1...4).should eql(L[4])
          list.send(method, -1..10).should eql(L[4])
          list.send(method, -1...10).should eql(L[4])
          list.send(method, -1..0).should eql(L.empty)
          list.send(method, -1..-4).should eql(L.empty)
          list.send(method, -1...-4).should eql(L.empty)
          list.send(method, -1..-6).should eql(L.empty)
          list.send(method, -1...-6).should eql(L.empty)
          list.send(method, -2..-2).should eql(L[3])
          list.send(method, -2...-2).should eql(L.empty)
          list.send(method, -2..-1).should eql(L[3,4])
          list.send(method, -2...-1).should eql(L[3])
          list.send(method, -2..10).should eql(L[3,4])
          list.send(method, -2...10).should eql(L[3,4])

          big.send(method, -1..-1).should eql(L[10000])
          big.send(method, -1..9999).should eql(L[10000])
          big.send(method, -1...9999).should eql(L.empty)
          big.send(method, -2...9999).should eql(L[9999])
          big.send(method, -2..-1).should eql(L[9999,10000])

          list.send(method, -4..-4).should eql(L[1])
          list.send(method, -4..-2).should eql(L[1,2,3])
          list.send(method, -4...-2).should eql(L[1,2])
          list.send(method, -4..-1).should eql(L[1,2,3,4])
          list.send(method, -4...-1).should eql(L[1,2,3])
          list.send(method, -4..3).should eql(L[1,2,3,4])
          list.send(method, -4...3).should eql(L[1,2,3])
          list.send(method, -4..4).should eql(L[1,2,3,4])
          list.send(method, -4...4).should eql(L[1,2,3,4])
          list.send(method, -4..0).should eql(L[1])
          list.send(method, -4...0).should eql(L.empty)
          list.send(method, -4..1).should eql(L[1,2])
          list.send(method, -4...1).should eql(L[1])

          list.send(method, -5..-5).should be_nil
          list.send(method, -5...-5).should be_nil
          list.send(method, -5..-4).should be_nil
          list.send(method, -5..-1).should be_nil
          list.send(method, -5..10).should be_nil

          big.send(method, -10001..-1).should be_nil
        end

        it "leaves the original unchanged" do
          list.should eql(L[1,2,3,4])
        end
      end
    end

    context "when passed a subclass of Range" do
      it "works the same as with a Range" do
        subclass = Class.new(Range)
        list.send(method, subclass.new(1,2)).should eql(L[2,3])
        list.send(method, subclass.new(-3,-1,true)).should eql(L[2,3])
      end
    end
  end
end