require "spec_helper"
require "hamster/nested"
require "hamster/deque"
require "set"

describe Hamster do
  expectations = [
    # [Ruby, Hamster]
    [ { "a" => 1,
        "b" => [2, {"c" => 3}, 4],
        "d" => ::Set.new([5, 6, 7]),
        "e" => {"f" => 8, "g" => 9},
        "h" => Regexp.new("ijk"),
        "l" => ::SortedSet.new([1, 2, 3]) },
      Hamster::Hash[
        "a" => 1,
        "b" => Hamster::Vector[2, Hamster::Hash["c" => 3], 4],
        "d" => Hamster::Set[5, 6, 7],
        "e" => Hamster::Hash["f" => 8, "g" => 9],
        "h" => Regexp.new("ijk"),
        "l" => Hamster::SortedSet.new([1, 2, 3])] ],
    [ {}, Hamster::Hash[] ],
    [ {"a" => 1, "b" => 2, "c" => 3}, Hamster::Hash["a" => 1, "b" => 2, "c" => 3] ],
    [ [], Hamster::Vector[] ],
    [ [1, 2, 3], Hamster::Vector[1, 2, 3] ],
    [ ::Set.new, Hamster::Set[] ],
    [ ::Set.new([1, 2, 3]), Hamster::Set[1, 2, 3] ],
    [ ::SortedSet.new, Hamster::SortedSet[] ],
    [ ::SortedSet.new([1, 2, 3]), Hamster::SortedSet[1, 2, 3] ],
    [ 42, 42 ],
    [ STDOUT, STDOUT ],

    # Struct conversion is one-way (from Ruby core Struct to Hamster::Hash), not back again!
    [ Struct::Customer.new, Hamster::Hash[name: nil, address: nil], true ],
    [ Struct::Customer.new('Dave', '123 Main'), Hamster::Hash[name: 'Dave', address: '123 Main'], true ]
  ]

  describe ".from" do
    expectations.each do |input, expected_result|
      context "with #{input.inspect} as input" do
        it "should return #{expected_result.inspect}" do
          Hamster.from(input).should eql(expected_result)
        end
      end
    end

    context "with mixed object" do
      it "should return Hamster data" do
        input = {
          "a" => "b",
          "c" => {"d" => "e"},
          "f" => Hamster::Vector["g", "h", []],
          "i" => Hamster::Hash["j" => {}, "k" => Hamster::Set[[], {}]] }
        expected_result = Hamster::Hash[
          "a" => "b",
          "c" => Hamster::Hash["d" => "e"],
          "f" => Hamster::Vector["g", "h", Hamster::EmptyVector],
          "i" => Hamster::Hash["j" => Hamster::EmptyHash, "k" => Hamster::Set[Hamster::EmptyVector, Hamster::EmptyHash]] ]
        Hamster.from(input).should eql(expected_result)
      end
    end
  end

  describe ".to_ruby" do
    expectations.each do |expected_result, input, one_way|
      unless one_way
        context "with #{input.inspect} as input" do
          it "should return #{expected_result.inspect}" do
            Hamster.to_ruby(input).should eql(expected_result)
          end
        end
      end
    end

    context "with Hamster::Deque[] as input" do
      it "should return []" do
        Hamster.to_ruby(Hamster::Deque[]).should eql([])
      end
    end

    context "with Hamster::Deque[Hamster::Hash[\"a\" => 1]] as input" do
      it "should return [{\"a\" => 1}]" do
        Hamster.to_ruby(Hamster::Deque[Hamster::Hash["a" => 1]]).should eql([{"a" => 1}])
      end
    end

    context "with mixed object" do
      it "should return Ruby data structures" do
        input = Hamster::Hash[
          "a" => "b",
          "c" => {"d" => "e"},
          "f" => Hamster::Vector["g", "h"],
          "i" => {"j" => Hamster::EmptyHash, "k" => Set.new([Hamster::EmptyVector, Hamster::EmptyHash])}]
        expected_result = {
          "a" => "b",
          "c" => {"d" => "e"},
          "f" => ["g", "h"],
          "i" => {"j" => {}, "k" => Set.new([[], {}])} }
        Hamster.to_ruby(input).should eql(expected_result)
      end
    end
  end
end
