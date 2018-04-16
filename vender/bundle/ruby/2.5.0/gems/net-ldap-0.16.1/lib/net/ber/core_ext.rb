# -*- ruby encoding: utf-8 -*-
require 'net/ber/ber_parser'
# :stopdoc:
class IO
  include Net::BER::BERParser
end

class StringIO
  include Net::BER::BERParser
end

if defined? ::OpenSSL
  class OpenSSL::SSL::SSLSocket
    include Net::BER::BERParser
  end
end
# :startdoc:

module Net::BER::Extensions # :nodoc:
end

require 'net/ber/core_ext/string'
# :stopdoc:
class String
  include Net::BER::BERParser
  include Net::BER::Extensions::String
end

require 'net/ber/core_ext/array'
# :stopdoc:
class Array
  include Net::BER::Extensions::Array
end
# :startdoc:

require 'net/ber/core_ext/integer'
# :stopdoc:
class Integer
  include Net::BER::Extensions::Integer
end
# :startdoc:

require 'net/ber/core_ext/true_class'
# :stopdoc:
class TrueClass
  include Net::BER::Extensions::TrueClass
end
# :startdoc:

require 'net/ber/core_ext/false_class'
# :stopdoc:
class FalseClass
  include Net::BER::Extensions::FalseClass
end
# :startdoc:
