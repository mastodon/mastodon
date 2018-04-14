# Define some basic Sprockets error classes
module Sprockets
  class Error           < StandardError; end
  class ArgumentError           < Error; end
  class ContentTypeMismatch     < Error; end
  class NotImplementedError     < Error; end
  class NotFound                < Error; end
  class ConversionError         < NotFound; end
  class FileNotFound            < NotFound; end
  class FileOutsidePaths        < NotFound; end
end
