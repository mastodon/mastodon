module Seahorse
  module Client
    # This utility class is used to track files opened by Seahorse.
    # This allows Seahorse to know what files it needs to close.
    class ManagedFile < File

      # @return [Boolean]
      def open?
        !closed?
      end

    end
  end
end
