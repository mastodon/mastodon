
module Rufus

  class Scheduler

    #
    # The array rufus-scheduler uses to keep jobs in order (next to trigger
    # first).
    #
    class JobArray

      def initialize

        @mutex = Mutex.new
        @array = []
      end

      def push(job)

        @mutex.synchronize { @array << job unless @array.index(job) }

        self
      end

      def size

        @array.size
      end

      def each(now, &block)

        to_a.sort_by do |job|

          job.next_time || (now + 1)

        end.each do |job|

          nt = job.next_time
          break if ( ! nt) || (nt > now)

          block.call(job)
        end
      end

      def delete_unscheduled

        @mutex.synchronize {

          @array.delete_if { |j| j.next_time.nil? || j.unscheduled_at }
        }
      end

      def to_a

        @mutex.synchronize { @array.dup }
      end

      def [](job_id)

        @mutex.synchronize { @array.find { |j| j.job_id == job_id } }
      end

      # Only used when shutting down, directly yields the underlying array.
      #
      def array

        @array
      end
    end
  end
end

