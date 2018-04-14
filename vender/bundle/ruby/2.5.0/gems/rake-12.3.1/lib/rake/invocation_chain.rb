# frozen_string_literal: true
module Rake

  # InvocationChain tracks the chain of task invocations to detect
  # circular dependencies.
  class InvocationChain < LinkedList

    # Is the invocation already in the chain?
    def member?(invocation)
      head == invocation || tail.member?(invocation)
    end

    # Append an invocation to the chain of invocations. It is an error
    # if the invocation already listed.
    def append(invocation)
      if member?(invocation)
        fail RuntimeError, "Circular dependency detected: #{to_s} => #{invocation}"
      end
      conj(invocation)
    end

    # Convert to string, ie: TOP => invocation => invocation
    def to_s
      "#{prefix}#{head}"
    end

    # Class level append.
    def self.append(invocation, chain)
      chain.append(invocation)
    end

    private

    def prefix
      "#{tail} => "
    end

    # Null object for an empty chain.
    class EmptyInvocationChain < LinkedList::EmptyLinkedList
      @parent = InvocationChain

      def member?(obj)
        false
      end

      def append(invocation)
        conj(invocation)
      end

      def to_s
        "TOP"
      end
    end

    EMPTY = EmptyInvocationChain.new
  end
end
