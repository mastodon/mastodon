module IPAddress
  
  #
  # =NAME
  #   
  # IPAddress::Prefix
  #
  # =SYNOPSIS
  #  
  # Parent class for Prefix32 and Prefix128
  #
  # =DESCRIPTION
  #
  # IPAddress::Prefix is the parent class for IPAddress::Prefix32 
  # and IPAddress::Prefix128, defining some modules in common for
  # both the subclasses.
  #
  # IPAddress::Prefix shouldn't be accesses directly, unless
  # for particular needs.
  #
  class Prefix 

    include Comparable

    attr_reader :prefix

    #
    # Creates a new general prefix
    #
    def initialize(num)
      @prefix = num.to_i
    end

    #
    # Returns a string with the prefix 
    #
    def to_s
      "#@prefix"
    end
    alias_method :inspect, :to_s

    # 
    # Returns the prefix
    #
    def to_i
      @prefix
    end

    # 
    # Compare the prefix
    #
    def <=>(oth)
      @prefix <=> oth.to_i
    end

    #
    # Sums two prefixes or a prefix to a 
    # number, returns a Fixnum
    #
    def +(oth)
      if oth.is_a? Fixnum
        self.prefix + oth
      else
        self.prefix + oth.prefix
      end
    end

    #
    # Returns the difference between two
    # prefixes, or a prefix and a number,
    # as a Fixnum
    #
    def -(oth)
      if oth.is_a? Fixnum
        self.prefix - oth
      else
        (self.prefix - oth.prefix).abs
      end
    end
    
   end # class Prefix


  class Prefix32 < Prefix

    IN4MASK = 0xffffffff
    
    #
    # Creates a new prefix object for 32 bits IPv4 addresses
    #
    #   prefix = IPAddress::Prefix32.new 24
    #     #=> 24
    #
    def initialize(num)
      unless (0..32).include? num
        raise ArgumentError, "Prefix must be in range 0..32, got: #{num}"
      end
      super(num)
    end

    #
    # Returns the length of the host portion
    # of a netmask. 
    #
    #   prefix = Prefix32.new 24
    #
    #   prefix.host_prefix
    #     #=> 8
    #
    def host_prefix
      32 - @prefix
    end
    
    #
    # Transforms the prefix into a string of bits
    # representing the netmask
    #
    #   prefix = IPAddress::Prefix32.new 24
    # 
    #   prefix.bits 
    #     #=> "11111111111111111111111100000000"
    #
    def bits
      "%.32b" % to_u32
    end

    #
    # Gives the prefix in IPv4 dotted decimal format, 
    # i.e. the canonical netmask we're all used to
    #
    #   prefix = IPAddress::Prefix32.new 24
    #
    #   prefix.to_ip
    #     #=> "255.255.255.0"
    #
    def to_ip
      [bits].pack("B*").unpack("CCCC").join(".")
    end

    #
    # An array of octets of the IPv4 dotted decimal 
    # format 
    #
    #   prefix = IPAddress::Prefix32.new 24
    #
    #   prefix.octets
    #     #=> [255, 255, 255, 0]
    #
    def octets
      to_ip.split(".").map{|i| i.to_i}
    end

    #
    # Unsigned 32 bits decimal number representing
    # the prefix
    #
    #   prefix = IPAddress::Prefix32.new 24
    #
    #   prefix.to_u32
    #     #=> 4294967040
    #
    def to_u32
      (IN4MASK >> host_prefix) << host_prefix
    end
    
    #
    # Shortcut for the octecs in the dotted decimal 
    # representation
    #
    #   prefix = IPAddress::Prefix32.new 24
    #
    #   prefix[2]
    #     #=> 255
    #
    def [](index)
      octets[index]
    end

    #
    # The hostmask is the contrary of the subnet mask,
    # as it shows the bits that can change within the
    # hosts
    #
    #   prefix = IPAddress::Prefix32.new 24
    #
    #   prefix.hostmask
    #     #=> "0.0.0.255"
    #
    def hostmask
      [~to_u32].pack("N").unpack("CCCC").join(".")
    end
    
    #
    # Creates a new prefix by parsing a netmask in 
    # dotted decimal form
    #
    #   prefix = IPAddress::Prefix32::parse_netmask "255.255.255.0"
    #     #=> 24
    #
    def self.parse_netmask(netmask)
      octets = netmask.split(".").map{|i| i.to_i}
      num = octets.pack("C"*octets.size).unpack("B*").first.count "1"
      return self.new(num)
    end
    
  end # class Prefix32 < Prefix

  class Prefix128 < Prefix

    #
    # Creates a new prefix object for 128 bits IPv6 addresses
    #
    #   prefix = IPAddress::Prefix128.new 64
    #     #=> 64
    #
    def initialize(num=128)
      unless (0..128).include? num.to_i
        raise ArgumentError, "Prefix must be in range 0..128, got: #{num}"
      end
      super(num.to_i)
    end

    #
    # Transforms the prefix into a string of bits
    # representing the netmask
    #
    #   prefix = IPAddress::Prefix128.new 64
    #
    #   prefix.bits
    #     #=> "1111111111111111111111111111111111111111111111111111111111111111"
    #         "0000000000000000000000000000000000000000000000000000000000000000"
    #
    def bits
      "1" * @prefix + "0" * (128 - @prefix)
    end

    #
    # Unsigned 128 bits decimal number representing
    # the prefix
    #
    #   prefix = IPAddress::Prefix128.new 64
    #
    #   prefix.to_u128
    #     #=> 340282366920938463444927863358058659840
    #
    def to_u128
      bits.to_i(2)
    end

    #
    # Returns the length of the host portion
    # of a netmask. 
    #
    #   prefix = Prefix128.new 96
    #
    #   prefix.host_prefix
    #     #=> 32
    #
    def host_prefix
      128 - @prefix
    end

  end # class Prefix123 < Prefix

end # module IPAddress
