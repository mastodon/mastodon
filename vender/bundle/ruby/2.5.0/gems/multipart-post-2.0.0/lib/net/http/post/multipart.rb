#--
# Copyright (c) 2007-2012 Nick Sieger.
# See the file README.txt included with the distribution for
# software license details.
#++

require 'net/http'
require 'stringio'
require 'cgi'
require 'composite_io'
require 'multipartable'
require 'parts'

module Net #:nodoc:
  class HTTP #:nodoc:
    class Put
      class Multipart < Put
        include Multipartable
      end
    end
    class Post #:nodoc:
      class Multipart < Post
        include Multipartable
      end
    end
  end
end
