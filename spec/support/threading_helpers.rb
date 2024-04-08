# frozen_string_literal: true

module ThreadingHelpers
  def multi_threaded_execution(thread_count)
    wait_for_start = true

    threads = Array.new(thread_count) do
      Thread.new do
        true while wait_for_start
        yield
      end
    end

    wait_for_start = false
    threads.each(&:join)
  end
end
