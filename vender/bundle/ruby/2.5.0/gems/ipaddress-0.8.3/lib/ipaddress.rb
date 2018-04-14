#
# = IPAddress
#
# A ruby library to manipulate IPv4 and IPv6 addresses
#
#
# Package::     IPAddress
# Author::      Marco Ceresa <ceresa@ieee.org>
# License::     Ruby License
#
#--
#
#++

require 'ipaddress/ipv4'
require 'ipaddress/ipv6'
require 'ipaddress/mongoid' if defined?(Mongoid)

module IPAddress

  NAME            = "IPAddress"
  GEM             = "ipaddress"
  AUTHORS         = ["Marco Ceresa <ceresa@ieee.org>"]

  #
  # Parse the argument string to create a new
  # IPv4, IPv6 or Mapped IP object
  #
  #   ip  = IPAddress.parse 167837953 # 10.1.1.1  
  #   ip  = IPAddress.parse "172.16.10.1/24"
  #   ip6 = IPAddress.parse "2001:db8::8:800:200c:417a/64"
  #   ip_mapped = IPAddress.parse "::ffff:172.16.10.1/128"
  #
  # All the object created will be instances of the 
  # correct class:
  #
  #  ip.class
  #    #=> IPAddress::IPv4
  #  ip6.class
  #    #=> IPAddress::IPv6
  #  ip_mapped.class
  #    #=> IPAddress::IPv6::Mapped
  #
  def IPAddress::parse(str)
    
    # Check if an int was passed
    if str.kind_of? Integer
      return IPAddress::IPv4.new(ntoa(str))  
    end

    case str
    when /:.+\./
      IPAddress::IPv6::Mapped.new(str)
    when /\./
      IPAddress::IPv4.new(str) 
    when /:/
      IPAddress::IPv6.new(str)
    else
      raise ArgumentError, "Unknown IP Address #{str}"
    end
  end

  #
  # Converts a unit32 to IPv4
  #
  #   IPAddress::ntoa(167837953)
  #     #-> "10.1.1.1"
  #
  def self.ntoa(uint)
    unless(uint.is_a? Numeric and uint <= 0xffffffff and uint >= 0)
        raise(::ArgumentError, "not a long integer: #{uint.inspect}")
      end
      ret = []
      4.times do 
        ret.unshift(uint & 0xff)
        uint >>= 8
      end
      ret.join('.')
  end

  #
  # True if the object is an IPv4 address
  #
  #   ip = IPAddress("192.168.10.100/24")
  #
  #   ip.ipv4?
  #     #-> true
  #
  def ipv4?
    self.kind_of? IPAddress::IPv4
  end
  
  #
  # True if the object is an IPv6 address
  #
  #   ip = IPAddress("192.168.10.100/24")
  #
  #   ip.ipv6?
  #     #-> false
  #
  def ipv6?
    self.kind_of? IPAddress::IPv6
  end

  # 
  # Checks if the given string is a valid IP address,
  # either IPv4 or IPv6
  #
  # Example:
  #
  #   IPAddress::valid? "2002::1"
  #     #=> true
  #
  #   IPAddress::valid? "10.0.0.256"   
  #     #=> false
  #
  def self.valid?(addr)
    valid_ipv4?(addr) || valid_ipv6?(addr)
  end
  
  #
  # Checks if the given string is a valid IPv4 address
  #
  # Example:
  #
  #   IPAddress::valid_ipv4? "2002::1"
  #     #=> false
  #
  #   IPAddress::valid_ipv4? "172.16.10.1"
  #     #=> true
  #
  def self.valid_ipv4?(addr)
    if /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\Z/ =~ addr
      return $~.captures.all? {|i| i.to_i < 256}
    end
    false
  end
  
  #
  # Checks if the argument is a valid IPv4 netmask
  # expressed in dotted decimal format.
  #
  #   IPAddress.valid_ipv4_netmask? "255.255.0.0"
  #     #=> true
  #
  def self.valid_ipv4_netmask?(addr)
    arr = addr.split(".").map{|i| i.to_i}.pack("CCCC").unpack("B*").first.scan(/01/)
    arr.empty? && valid_ipv4?(addr)
  rescue
    return false
  end
  
  #
  # Checks if the given string is a valid IPv6 address
  #
  # Example:
  #
  #   IPAddress::valid_ipv6? "2002::1"
  #     #=> true
  #
  #   IPAddress::valid_ipv6? "2002::DEAD::BEEF"
  #     #=> false
  #
  def self.valid_ipv6?(addr) 
    # https://gist.github.com/cpetschnig/294476
    # http://forums.intermapper.com/viewtopic.php?t=452
    return true if /^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/ =~ addr
    false
  end

  # 
  # Deprecate method
  #
  def self.deprecate(message = nil) # :nodoc:
    message ||= "You are using deprecated behavior which will be removed from the next major or minor release."
    warn("DEPRECATION WARNING: #{message}")
  end
  
end # module IPAddress

#
# IPAddress is a wrapper method built around 
# IPAddress's library classes. Its purpouse is to 
# make you indipendent from the type of IP address 
# you're going to use.
#
# For example, instead of creating the three types 
# of IP addresses using their own contructors
#
#   ip  = IPAddress::IPv4.new "172.16.10.1/24"
#   ip6 = IPAddress::IPv6.new "2001:db8::8:800:200c:417a/64"
#   ip_mapped = IPAddress::IPv6::Mapped "::ffff:172.16.10.1/128" 
#
# you can just use the IPAddress wrapper:
#
#   ip  = IPAddress "172.16.10.1/24"
#   ip6 = IPAddress "2001:db8::8:800:200c:417a/64"
#   ip_mapped = IPAddress "::ffff:172.16.10.1/128"
#
# All the object created will be instances of the 
# correct class:
#
#  ip.class
#    #=> IPAddress::IPv4
#  ip6.class
#    #=> IPAddress::IPv6
#  ip_mapped.class
#    #=> IPAddress::IPv6::Mapped
#
def IPAddress(str)
  IPAddress::parse str
end

#
# Compatibility with Ruby 1.8
#
if RUBY_VERSION =~ /^1\.8/
  class Hash # :nodoc:
    alias :key :index
  end
  module Math # :nodoc:
    def Math.log2(n) 
      log(n) / log(2) 
    end
  end
end

