module RQRCode
  module CoreExtensions #:nodoc:
    module Array #:nodoc:
      module Behavior
        def extract_options!
          last.is_a?(::Hash) ? pop : {}
        end unless [].respond_to?(:extract_options!)
      end
    end
  end
end

