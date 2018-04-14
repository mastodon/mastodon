require "spec_helper"
require "hamster/vector"

describe Hamster::Vector do
  describe "#eql" do
    let(:vector) { V["A", "B", "C"] }

    it "returns false when comparing with an array with the same contents" do
      vector.eql?(%w[A B C]).should == false
    end

    it "returns false when comparing with an arbitrary object" do
      vector.eql?(Object.new).should == false
    end

    it "returns false when comparing an empty vector with an empty array" do
      V.empty.eql?([]).should == false
    end

    it "returns false when comparing with a subclass of Hamster::Vector" do
      vector.eql?(Class.new(Hamster::Vector).new(%w[A B C])).should == false
    end
  end

  describe "#==" do
    let(:vector) { V["A", "B", "C"] }

    it "returns true when comparing with an array with the same contents" do
      (vector == %w[A B C]).should == true
    end

    it "returns false when comparing with an arbitrary object" do
      (vector == Object.new).should == false
    end

    it "returns true when comparing an empty vector with an empty array" do
      (V.empty == []).should == true
    end

    it "returns true when comparing with a subclass of Hamster::Vector" do
      (vector == Class.new(Hamster::Vector).new(%w[A B C])).should == true
    end

    it "works on larger vectors" do
      array = 2000.times.map { rand(10000) }
      (V.new(array.dup) == array).should == true
    end
  end

  [:eql?, :==].each do |method|
    describe "##{method}" do
      [
        [[], [], true],
        [[], [nil], false],
        [["A"], [], false],
        [["A"], ["A"], true],
        [["A"], ["B"], false],
        [%w[A B], ["A"], false],
        [%w[A B C], %w[A B C], true],
        [%w[C A B], %w[A B C], false],
      ].each do |a, b, expected|
        describe "returns #{expected.inspect}" do
          let(:vector_a) { V[*a] }
          let(:vector_b) { V[*b] }

          it "for vectors #{a.inspect} and #{b.inspect}" do
            vector_a.send(method, vector_b).should == expected
          end

          it "for vectors #{b.inspect} and #{a.inspect}" do
            vector_b.send(method, vector_a).should == expected
          end
        end
      end
    end
  end
end