# frozen_string_literal: true

require 'concurrent/atomic/cyclic_barrier'

module ThreadingHelpers
  def multi_threaded_execution(thread_count)
    barrier = Concurrent::CyclicBarrier.new(thread_count)

    threads = Array.new(thread_count) do |index|
      Thread.new do
        barrier.wait
        yield(index)
      end
    end

    threads.each(&:join)
  end
end
