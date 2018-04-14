# frozen_string_literal: true
module Rake
  module InvocationExceptionMixin
    # Return the invocation chain (list of Rake tasks) that were in
    # effect when this exception was detected by rake.  May be null if
    # no tasks were active.
    def chain
      @rake_invocation_chain ||= nil
    end

    # Set the invocation chain in effect when this exception was
    # detected.
    def chain=(value)
      @rake_invocation_chain = value
    end
  end
end
