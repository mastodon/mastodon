require "spec_helper"
require "hamster/deque"

describe Hamster::Deque do
  describe ".new" do
    it "accepts a single enumerable argument and creates a new deque" do
      deque = Hamster::Deque.new([1,2,3])
      deque.size.should be(3)
      deque.first.should be(1)
      deque.dequeue.first.should be(2)
      deque.dequeue.dequeue.first.should be(3)
    end

    it "is amenable to overriding of #initialize" do
      class SnazzyDeque < Hamster::Deque
        def initialize
          super(['SNAZZY!!!'])
        end
      end

      deque = SnazzyDeque.new
      deque.size.should be(1)
      deque.to_a.should == ['SNAZZY!!!']
    end

    context "from a subclass" do
      it "returns a frozen instance of the subclass" do
        subclass = Class.new(Hamster::Deque)
        instance = subclass.new(["some", "values"])
        instance.class.should be subclass
        instance.frozen?.should be true
      end
    end
  end

  describe ".[]" do
    it "accepts a variable number of items and creates a new deque" do
      deque = Hamster::Deque['a', 'b']
      deque.size.should be(2)
      deque.first.should == 'a'
      deque.dequeue.first.should == 'b'
    end
  end
end