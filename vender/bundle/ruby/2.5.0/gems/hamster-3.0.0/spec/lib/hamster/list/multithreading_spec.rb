require "spec_helper"
require "hamster/list"
require "concurrent/atomics"

describe Hamster::List do
  it "ensures each node of a lazy list will only be realized on ONE thread, even when accessed by multiple threads" do
    counter = Concurrent::AtomicReference.new(0)
    list = (1..10000).to_list.map { |x| counter.update { |count| count + 1 }; x * 2 }

    threads = 10.times.collect do
      Thread.new do
        node = list
        node = node.tail until node.empty?
      end
    end
    threads.each(&:join)

    counter.get.should == 10000
    list.sum.should == 100010000
  end

  it "doesn't go into an infinite loop if lazy list block raises an exception" do
    list = (1..10).to_list.map { raise "Oops!" }

    threads = 10.times.collect do
      Thread.new do
        -> { list.head }.should raise_error(RuntimeError)
      end
    end
    threads.each(&:join)
  end

  it "doesn't give horrendously bad performance if thread realizing the list sleeps" do
    start = Time.now
    list  = (1..100).to_list.map { |x| sleep(0.001); x * 2 }

    threads = 10.times.collect do
      Thread.new do
        node = list
        node = node.tail until node.empty?
      end
    end
    threads.each(&:join)

    elapsed = Time.now - start
    elapsed.should_not > 0.3
  end
end