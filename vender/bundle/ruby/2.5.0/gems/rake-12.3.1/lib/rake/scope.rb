# frozen_string_literal: true
module Rake
  class Scope < LinkedList # :nodoc: all

    # Path for the scope.
    def path
      map(&:to_s).reverse.join(":")
    end

    # Path for the scope + the named path.
    def path_with_task_name(task_name)
      "#{path}:#{task_name}"
    end

    # Trim +n+ innermost scope levels from the scope. In no case will
    # this trim beyond the toplevel scope.
    def trim(n)
      result = self
      while n > 0 && ! result.empty?
        result = result.tail
        n -= 1
      end
      result
    end

    # Scope lists always end with an EmptyScope object. See Null
    # Object Pattern)
    class EmptyScope < EmptyLinkedList
      @parent = Scope

      def path
        ""
      end

      def path_with_task_name(task_name)
        task_name
      end
    end

    # Singleton null object for an empty scope.
    EMPTY = EmptyScope.new
  end
end
