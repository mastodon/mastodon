# can be required by other files to prevent them from having to open and nest Rack and Timeout
module Rack
  class Timeout
  end
end
