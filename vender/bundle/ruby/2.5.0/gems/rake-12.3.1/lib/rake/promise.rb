# frozen_string_literal: true
module Rake

  # A Promise object represents a promise to do work (a chore) in the
  # future. The promise is created with a block and a list of
  # arguments for the block. Calling value will return the value of
  # the promised chore.
  #
  # Used by ThreadPool.
  #
  class Promise               # :nodoc: all
    NOT_SET = Object.new.freeze # :nodoc:

    attr_accessor :recorder

    # Create a promise to do the chore specified by the block.
    def initialize(args, &block)
      @mutex = Mutex.new
      @result = NOT_SET
      @error = NOT_SET
      @args = args
      @block = block
    end

    # Return the value of this promise.
    #
    # If the promised chore is not yet complete, then do the work
    # synchronously. We will wait.
    def value
      unless complete?
        stat :sleeping_on, item_id: object_id
        @mutex.synchronize do
          stat :has_lock_on, item_id: object_id
          chore
          stat :releasing_lock_on, item_id: object_id
        end
      end
      error? ? raise(@error) : @result
    end

    # If no one else is working this promise, go ahead and do the chore.
    def work
      stat :attempting_lock_on, item_id: object_id
      if @mutex.try_lock
        stat :has_lock_on, item_id: object_id
        chore
        stat :releasing_lock_on, item_id: object_id
        @mutex.unlock
      else
        stat :bailed_on, item_id: object_id
      end
    end

    private

    # Perform the chore promised
    def chore
      if complete?
        stat :found_completed, item_id: object_id
        return
      end
      stat :will_execute, item_id: object_id
      begin
        @result = @block.call(*@args)
      rescue Exception => e
        @error = e
      end
      stat :did_execute, item_id: object_id
      discard
    end

    # Do we have a result for the promise
    def result?
      ! @result.equal?(NOT_SET)
    end

    # Did the promise throw an error
    def error?
      ! @error.equal?(NOT_SET)
    end

    # Are we done with the promise
    def complete?
      result? || error?
    end

    # free up these items for the GC
    def discard
      @args = nil
      @block = nil
    end

    # Record execution statistics if there is a recorder
    def stat(*args)
      @recorder.call(*args) if @recorder
    end

  end

end
