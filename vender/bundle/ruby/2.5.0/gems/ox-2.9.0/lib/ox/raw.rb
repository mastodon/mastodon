
module Ox
  # Raw elements are used to inject existing XML strings into a document
  # WARNING: Use of this feature can result in invalid XML, since `value` is
  # injected as-is.
  class Raw < Node
    # Creates a new Raw element with the specified value.
    # - +value+ [String] string value for the comment
    def initialize(value)
      super
    end

  end # Raw
end # Ox
