require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  [:map, :collect].each do |method|
    describe "##{method}" do
      context "when empty" do
        it "returns self" do
          H.empty.send(method) {}.should equal(H.empty)
        end
      end

      context "when not empty" do
        let(:hash) { H["A" => "aye", "B"  => "bee", "C" => "see"] }

        context "with a block" do
          let(:mapped) { hash.send(method) { |key, value| [key.downcase, value.upcase] }}

          it "preserves the original values" do
            mapped
            hash.should eql(H["A" => "aye", "B"  => "bee", "C" => "see"])
          end

          it "returns a new hash with the mapped values" do
            mapped.should eql(H["a" => "AYE", "b"  => "BEE", "c" => "SEE"])
          end
        end

        context "with no block" do
          it "returns an Enumerator" do
            hash.send(method).class.should be(Enumerator)
            hash.send(method).each { |k,v| [k.downcase, v] }.should == hash.map { |k,v| [k.downcase, v] }
          end
        end
      end

      context "from a subclass" do
        it "returns an instance of the subclass" do
          subclass = Class.new(Hamster::Hash)
          instance = subclass.new('a' => 'aye', 'b' => 'bee')
          instance.map { |k,v| [k, v.upcase] }.class.should be(subclass)
        end
      end
    end
  end
end