module Concurrent

  # @!macro atomic_reference
  class ConcurrentUpdateError < ThreadError
    # frozen pre-allocated backtrace to speed ConcurrentUpdateError
    CONC_UP_ERR_BACKTRACE = ['backtrace elided; set verbose to enable'].freeze
  end
end
