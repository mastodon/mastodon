module IPAddress

  #
  # Mongoid field serialization
  #
  # IPAddress objects are converted to String
  #
  #   IPAddress.mongoize IPAddress.parse("172.16.10.1")
  #     #=> "172.16.10.1"
  #
  # Prefix will be removed from host adresses
  #
  #   IPAddress.mongoize "172.16.10.1/32"
  #     #=> "172.16.10.1"
  #
  # Prefix will be kept for network addresses
  #
  #   IPAddress.mongoize "172.16.10.1/24"
  #     #=> "172.16.10.1/24"
  #
  # IPv6 addresses will be stored uncompressed to ease DB search and sorting
  #
  #   IPAddress.mongoize "2001:db8::8:800:200c:417a"
  #     #=> "2001:0db8:0000:0000:0008:0800:200c:417a"
  #   IPAddress.mongoize "2001:db8::8:800:200c:417a/64"
  #     #=> "2001:0db8:0000:0000:0008:0800:200c:417a/64"
  #
  # Invalid addresses will be serialized as nil
  #
  #   IPAddress.mongoize "invalid"
  #     #=> nil
  #   IPAddress.mongoize ""
  #     #=> nil
  #   IPAddress.mongoize 1
  #     #=> nil
  #   IPAddress.mongoize nil
  #     #=> nil
  #
  def self.mongoize(ipaddress)
    ipaddress = self.parse(ipaddress) unless ipaddress.is_a?(IPAddress)
    if ipaddress.bits.length == ipaddress.prefix
      ipaddress.address
    elsif ipaddress.is_a?(IPAddress::IPv6)
      ipaddress.to_string_uncompressed
    else
      ipaddress.to_string
    end
  rescue ArgumentError
    nil
  end

  #
  # Mongoid field deserialization
  #
  def self.demongoize(string)
    parse(string)
  rescue ArgumentError
    nil
  end

  #
  # Delegates to IPAddress.mongoize
  #
  def self.evolve(ipaddress)
    mongoize(ipaddress)
  end

  #
  # Sends self object to IPAddress#mongoize
  #
  def mongoize
    IPAddress.mongoize(self)
  end

end