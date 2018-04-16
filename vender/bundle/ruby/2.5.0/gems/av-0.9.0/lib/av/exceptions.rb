module Av
  class UnableToDetect < Exception; end
  class CommandError < Exception; end
  class InvalidInputFile < Exception; end
  class InvalidOutputFile < Exception; end
  class InvalidFilterParameter < Exception; end
  class FilterNotImplemented < Exception; end
end