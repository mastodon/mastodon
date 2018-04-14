require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  let(:vector) { V[1,2,3,4] }
  let(:big) { V.new(1..10000) }

  [:slice, :[]].each do |method|
    describe "##{method}" do
      context "when passed a positive integral index" do
        it "returns the element at that index" do
          vector.send(method, 0).should be(1)
          vector.send(method, 1).should be(2)
          vector.send(method, 2).should be(3)
          vector.send(method, 3).should be(4)
          vector.send(method, 4).should be(nil)
          vector.send(method, 10).should be(nil)

          big.send(method, 0).should be(1)
          big.send(method, 9999).should be(10000)
        end

        it "leaves the original unchanged" do
          vector.should eql(V[1,2,3,4])
        end
      end

      context "when passed a negative integral index" do
        it "returns the element which is number (index.abs) counting from the end of the vector" do
          vector.send(method, -1).should be(4)
          vector.send(method, -2).should be(3)
          vector.send(method, -3).should be(2)
          vector.send(method, -4).should be(1)
          vector.send(method, -5).should be(nil)
          vector.send(method, -10).should be(nil)

          big.send(method, -1).should be(10000)
          big.send(method, -10000).should be(1)
        end
      end

      context "when passed a positive integral index and count" do
        it "returns 'count' elements starting from 'index'" do
          vector.send(method, 0, 0).should  eql(V.empty)
          vector.send(method, 0, 1).should  eql(V[1])
          vector.send(method, 0, 2).should  eql(V[1,2])
          vector.send(method, 0, 4).should  eql(V[1,2,3,4])
          vector.send(method, 0, 6).should  eql(V[1,2,3,4])
          vector.send(method, 0, -1).should be_nil
          vector.send(method, 0, -2).should be_nil
          vector.send(method, 0, -4).should be_nil
          vector.send(method, 2, 0).should  eql(V.empty)
          vector.send(method, 2, 1).should  eql(V[3])
          vector.send(method, 2, 2).should  eql(V[3,4])
          vector.send(method, 2, 4).should  eql(V[3,4])
          vector.send(method, 2, -1).should be_nil
          vector.send(method, 4, 0).should  eql(V.empty)
          vector.send(method, 4, 2).should  eql(V.empty)
          vector.send(method, 4, -1).should be_nil
          vector.send(method, 5, 0).should  be_nil
          vector.send(method, 5, 2).should  be_nil
          vector.send(method, 5, -1).should be_nil
          vector.send(method, 6, 0).should  be_nil
          vector.send(method, 6, 2).should  be_nil
          vector.send(method, 6, -1).should be_nil

          big.send(method, 0, 3).should    eql(V[1,2,3])
          big.send(method, 1023, 4).should eql(V[1024,1025,1026,1027])
          big.send(method, 1024, 4).should eql(V[1025,1026,1027,1028])
        end

        it "leaves the original unchanged" do
          vector.should eql(V[1,2,3,4])
        end
      end

      context "when passed a negative integral index and count" do
        it "returns 'count' elements, starting from index which is number 'index.abs' counting from the end of the array" do
          vector.send(method, -1, 0).should  eql(V.empty)
          vector.send(method, -1, 1).should  eql(V[4])
          vector.send(method, -1, 2).should  eql(V[4])
          vector.send(method, -1, -1).should be_nil
          vector.send(method, -2, 0).should  eql(V.empty)
          vector.send(method, -2, 1).should  eql(V[3])
          vector.send(method, -2, 2).should  eql(V[3,4])
          vector.send(method, -2, 4).should  eql(V[3,4])
          vector.send(method, -2, -1).should be_nil
          vector.send(method, -4, 0).should  eql(V.empty)
          vector.send(method, -4, 1).should  eql(V[1])
          vector.send(method, -4, 2).should  eql(V[1,2])
          vector.send(method, -4, 4).should  eql(V[1,2,3,4])
          vector.send(method, -4, 6).should  eql(V[1,2,3,4])
          vector.send(method, -4, -1).should be_nil
          vector.send(method, -5, 0).should  be_nil
          vector.send(method, -5, 1).should  be_nil
          vector.send(method, -5, 10).should be_nil
          vector.send(method, -5, -1).should be_nil

          big.send(method, -1, 1).should eql(V[10000])
          big.send(method, -1, 2).should eql(V[10000])
          big.send(method, -6, 2).should eql(V[9995,9996])
        end
      end

      context "when passed a Range" do
        it "returns the elements whose indexes are within the given Range" do
          vector.send(method, 0..-1).should  eql(V[1,2,3,4])
          vector.send(method, 0..-10).should eql(V.empty)
          vector.send(method, 0..0).should   eql(V[1])
          vector.send(method, 0..1).should   eql(V[1,2])
          vector.send(method, 0..2).should   eql(V[1,2,3])
          vector.send(method, 0..3).should   eql(V[1,2,3,4])
          vector.send(method, 0..4).should   eql(V[1,2,3,4])
          vector.send(method, 0..10).should  eql(V[1,2,3,4])
          vector.send(method, 2..-10).should eql(V.empty)
          vector.send(method, 2..0).should   eql(V.empty)
          vector.send(method, 2..2).should   eql(V[3])
          vector.send(method, 2..3).should   eql(V[3,4])
          vector.send(method, 2..4).should   eql(V[3,4])
          vector.send(method, 3..0).should   eql(V.empty)
          vector.send(method, 3..3).should   eql(V[4])
          vector.send(method, 3..4).should   eql(V[4])
          vector.send(method, 4..0).should   eql(V.empty)
          vector.send(method, 4..4).should   eql(V.empty)
          vector.send(method, 4..5).should   eql(V.empty)
          vector.send(method, 5..0).should   be_nil
          vector.send(method, 5..5).should   be_nil
          vector.send(method, 5..6).should   be_nil

          big.send(method, 159..162).should     eql(V[160,161,162,163])
          big.send(method, 160..162).should     eql(V[161,162,163])
          big.send(method, 161..162).should     eql(V[162,163])
          big.send(method, 9999..10100).should  eql(V[10000])
          big.send(method, 10000..10100).should eql(V.empty)
          big.send(method, 10001..10100).should be_nil

          vector.send(method, 0...-1).should  eql(V[1,2,3])
          vector.send(method, 0...-10).should eql(V.empty)
          vector.send(method, 0...0).should   eql(V.empty)
          vector.send(method, 0...1).should   eql(V[1])
          vector.send(method, 0...2).should   eql(V[1,2])
          vector.send(method, 0...3).should   eql(V[1,2,3])
          vector.send(method, 0...4).should   eql(V[1,2,3,4])
          vector.send(method, 0...10).should  eql(V[1,2,3,4])
          vector.send(method, 2...-10).should eql(V.empty)
          vector.send(method, 2...0).should   eql(V.empty)
          vector.send(method, 2...2).should   eql(V.empty)
          vector.send(method, 2...3).should   eql(V[3])
          vector.send(method, 2...4).should   eql(V[3,4])
          vector.send(method, 3...0).should   eql(V.empty)
          vector.send(method, 3...3).should   eql(V.empty)
          vector.send(method, 3...4).should   eql(V[4])
          vector.send(method, 4...0).should   eql(V.empty)
          vector.send(method, 4...4).should   eql(V.empty)
          vector.send(method, 4...5).should   eql(V.empty)
          vector.send(method, 5...0).should   be_nil
          vector.send(method, 5...5).should   be_nil
          vector.send(method, 5...6).should   be_nil

          big.send(method, 159...162).should     eql(V[160,161,162])
          big.send(method, 160...162).should     eql(V[161,162])
          big.send(method, 161...162).should     eql(V[162])
          big.send(method, 9999...10100).should  eql(V[10000])
          big.send(method, 10000...10100).should eql(V.empty)
          big.send(method, 10001...10100).should be_nil

          vector.send(method, -1..-1).should  eql(V[4])
          vector.send(method, -1...-1).should eql(V.empty)
          vector.send(method, -1..3).should   eql(V[4])
          vector.send(method, -1...3).should  eql(V.empty)
          vector.send(method, -1..4).should   eql(V[4])
          vector.send(method, -1...4).should  eql(V[4])
          vector.send(method, -1..10).should  eql(V[4])
          vector.send(method, -1...10).should eql(V[4])
          vector.send(method, -1..0).should   eql(V.empty)
          vector.send(method, -1..-4).should  eql(V.empty)
          vector.send(method, -1...-4).should eql(V.empty)
          vector.send(method, -1..-6).should  eql(V.empty)
          vector.send(method, -1...-6).should eql(V.empty)
          vector.send(method, -2..-2).should  eql(V[3])
          vector.send(method, -2...-2).should eql(V.empty)
          vector.send(method, -2..-1).should  eql(V[3,4])
          vector.send(method, -2...-1).should eql(V[3])
          vector.send(method, -2..10).should  eql(V[3,4])
          vector.send(method, -2...10).should eql(V[3,4])

          big.send(method, -1..-1).should    eql(V[10000])
          big.send(method, -1..9999).should  eql(V[10000])
          big.send(method, -1...9999).should eql(V.empty)
          big.send(method, -2...9999).should eql(V[9999])
          big.send(method, -2..-1).should    eql(V[9999,10000])

          vector.send(method, -4..-4).should  eql(V[1])
          vector.send(method, -4..-2).should  eql(V[1,2,3])
          vector.send(method, -4...-2).should eql(V[1,2])
          vector.send(method, -4..-1).should  eql(V[1,2,3,4])
          vector.send(method, -4...-1).should eql(V[1,2,3])
          vector.send(method, -4..3).should   eql(V[1,2,3,4])
          vector.send(method, -4...3).should  eql(V[1,2,3])
          vector.send(method, -4..4).should   eql(V[1,2,3,4])
          vector.send(method, -4...4).should  eql(V[1,2,3,4])
          vector.send(method, -4..0).should   eql(V[1])
          vector.send(method, -4...0).should  eql(V.empty)
          vector.send(method, -4..1).should   eql(V[1,2])
          vector.send(method, -4...1).should  eql(V[1])

          vector.send(method, -5..-5).should be_nil
          vector.send(method, -5...-5).should be_nil
          vector.send(method, -5..-4).should be_nil
          vector.send(method, -5..-1).should be_nil
          vector.send(method, -5..10).should be_nil

          big.send(method, -10001..-1).should be_nil
        end

        it "leaves the original unchanged" do
          vector.should eql(V[1,2,3,4])
        end
      end
    end

    context "when passed a subclass of Range" do
      it "works the same as with a Range" do
        subclass = Class.new(Range)
        vector.send(method, subclass.new(1,2)).should eql(V[2,3])
        vector.send(method, subclass.new(-3,-1,true)).should eql(V[2,3])
      end
    end

    context "on a subclass of Vector" do
      it "with index and count or a range, returns an instance of the subclass" do
        subclass = Class.new(Hamster::Vector)
        instance = subclass.new([1,2,3])
        instance.send(method, 0, 0).class.should be(subclass)
        instance.send(method, 0, 2).class.should be(subclass)
        instance.send(method, 0..0).class.should be(subclass)
        instance.send(method, 1..-1).class.should be(subclass)
      end
    end
  end
end