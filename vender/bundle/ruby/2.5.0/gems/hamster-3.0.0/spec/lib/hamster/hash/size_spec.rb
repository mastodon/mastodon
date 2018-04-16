require "spec_helper"
require "hamster/hash"

describe Hamster::Hash do
  [:size, :length].each do |method|
    describe "##{method}" do
      [
        [[], 0],
        [["A" => "aye"], 1],
        [["A" => "bee", "B" => "bee", "C" => "see"], 3],
      ].each do |values, result|

        it "returns #{result} for #{values.inspect}" do
          H[*values].send(method).should == result
        end
      end

      lots = (1..10_842).to_a
      srand 89_533_474
      random_things = (lots + lots).sort_by { |x|rand }

      it "has the correct size after adding lots of things with colliding keys and such" do
        h = H.empty
        random_things.each do |thing|
          h = h.put(thing, thing * 2)
        end
        h.size.should == 10_842
      end

      random_actions = (lots.map { |x|[:add, x] } + lots.map { |x|[:add, x] } + lots.map { |x|[:remove, x] }).sort_by { |x|rand }
      ending_size = random_actions.reduce({}) do |h, (act, ob)|
        if act == :add
          h[ob] = 1
        else
          h.delete(ob)
        end
        h
      end.size
      it "has the correct size after lots of addings and removings" do
        h = H.empty
        random_actions.each do |(act, ob)|
          if act == :add
            h = h.put(ob, ob * 3)
          else
            h = h.delete(ob)
          end
        end
        h.size.should == ending_size
      end
    end
  end
end
